using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class FriendData
    {
        public int UserId { get; set; }
        public int OtherUserId { get; set; }
        public float Label { get; set; }
    }

    public class FriendPrediction
    {
        public float Score { get; set; }
    }

    public class FriendRecommendationResponse
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public float SimilarityScore { get; set; }
        public int TroopId { get; set; }
        public string TroopName { get; set; } = string.Empty;
    }

    public class UserInteractionCounts
    {
        public int CommonActivities { get; set; }
        public int SharedLikes { get; set; }
        public int SharedComments { get; set; }
        public int DirectLikes { get; set; }
        public int ReciprocalLikes { get; set; }
        public int DirectComments { get; set; }
        public int ReciprocalComments { get; set; }
        public int CommonReviews { get; set; }
    }

    public class FriendshipService : BaseCRUDService<FriendshipResponse, FriendshipSearchObject, Friendship, FriendshipUpsertRequest, FriendshipUpsertRequest>, IFriendshipService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<FriendshipService> _logger;
        private readonly MLContext _mlContext;
        private ITransformer? _model;
        private readonly string _modelPath = Path.Combine(Directory.GetCurrentDirectory(), "Models", "FriendRecommendationModel.zip");
        
        private readonly Dictionary<int, (List<FriendRecommendationResponse> Data, DateTime Timestamp)> _cache = new();
        private readonly TimeSpan _cacheExpiry = TimeSpan.FromMinutes(5);
        
        private PredictionEngine<FriendData, FriendPrediction>? _cachedPredictionEngine;
        private readonly object _predictionEngineLock = new object();
        private DateTime _lastPredictionEngineCreation = DateTime.MinValue;
        private readonly TimeSpan _predictionEngineLifetime = TimeSpan.FromHours(1);

        public FriendshipService(ScoutTrackDbContext context, IMapper mapper, ILogger<FriendshipService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _mlContext = new MLContext();
            LoadModelIfExists();
        }

        public override async Task<PagedResult<FriendshipResponse>> GetAsync(FriendshipSearchObject search)
        {
            var query = _context.Set<Friendship>().Include(f => f.Requester).Include(f => f.Responder).AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount) totalCount = await query.CountAsync();

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;
                bool descending = orderBy.StartsWith("-");
                if (descending) orderBy = orderBy[1..];

                query = orderBy.ToLower() switch
                {
                    "requestedat" => descending ? query.OrderByDescending(f => f.RequestedAt) : query.OrderBy(f => f.RequestedAt),
                    "respondedat" => descending ? query.OrderByDescending(f => f.RespondedAt) : query.OrderBy(f => f.RespondedAt),
                    "status" => descending ? query.OrderByDescending(f => f.Status) : query.OrderBy(f => f.Status),
                    _ => query
                };
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var entities = await query.ToListAsync();
            return new PagedResult<FriendshipResponse> { Items = entities.Select(MapToResponse).ToList(), TotalCount = totalCount };
        }

        protected override IQueryable<Friendship> ApplyFilter(IQueryable<Friendship> query, FriendshipSearchObject search)
        {
            if (search.RequesterId.HasValue) query = query.Where(f => f.RequesterId == search.RequesterId.Value);
            if (search.ResponderId.HasValue) query = query.Where(f => f.ResponderId == search.ResponderId.Value);
            if (search.Status.HasValue) query = query.Where(f => f.Status == search.Status.Value);
            if (search.MemberId.HasValue) query = query.Where(f => f.RequesterId == search.MemberId.Value || f.ResponderId == search.MemberId.Value);
            
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(f => f.Requester.Username.Contains(search.FTS) || f.Requester.FirstName.Contains(search.FTS) || 
                                        f.Requester.LastName.Contains(search.FTS) || f.Responder.Username.Contains(search.FTS) || 
                                        f.Responder.FirstName.Contains(search.FTS) || f.Responder.LastName.Contains(search.FTS));
            }
            return query;
        }

        public override async Task<FriendshipResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Friendships.Include(f => f.Requester).Include(f => f.Responder).FirstOrDefaultAsync(f => f.Id == id);
            return entity == null ? null : MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Friendship entity, FriendshipUpsertRequest request)
        {
            if (!await _context.Members.AnyAsync(m => m.Id == request.RequesterId))
                throw new UserException($"Requester with ID {request.RequesterId} does not exist.");
            if (!await _context.Members.AnyAsync(m => m.Id == request.ResponderId))
                throw new UserException($"Responder with ID {request.ResponderId} does not exist.");
            if (request.RequesterId == request.ResponderId)
                throw new UserException("Cannot send friend request to yourself.");

            var existingFriendship = await _context.Friendships.FirstOrDefaultAsync(f => 
                (f.RequesterId == request.RequesterId && f.ResponderId == request.ResponderId) ||
                (f.RequesterId == request.ResponderId && f.ResponderId == request.RequesterId));

            if (existingFriendship != null)
            {
                if (existingFriendship.Status == FriendshipStatus.Pending)
                    throw new UserException("Friend request already exists and is pending.");
                if (existingFriendship.Status == FriendshipStatus.Accepted)
                    throw new UserException("You are already friends with this person.");
            }

            entity.RequestedAt = DateTime.Now;
            entity.Status = FriendshipStatus.Pending;
        }

        protected override async Task BeforeUpdate(Friendship entity, FriendshipUpsertRequest request)
        {
            if (entity.RequesterId != request.RequesterId || entity.ResponderId != request.ResponderId)
                throw new UserException("Cannot change requester or responder of an existing friendship.");
            if (request.Status == FriendshipStatus.Accepted) entity.RespondedAt = DateTime.Now;
        }

        public async Task<FriendshipResponse?> SendFriendRequestAsync(int requesterId, int responderId)
        {
            var result = await CreateAsync(new FriendshipUpsertRequest { RequesterId = requesterId, ResponderId = responderId, Status = FriendshipStatus.Pending });
            ClearCache(requesterId, responderId);
            return result;
        }

        public async Task<FriendshipResponse?> AcceptFriendRequestAsync(int friendshipId, int responderId)
        {
            var friendship = await _context.Friendships.Include(f => f.Requester).Include(f => f.Responder)
                .FirstOrDefaultAsync(f => f.Id == friendshipId && f.ResponderId == responderId);
            if (friendship == null) return null;
            if (friendship.Status != FriendshipStatus.Pending) throw new UserException("This friend request is not pending.");

            friendship.Status = FriendshipStatus.Accepted;
            friendship.RespondedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            ClearCache(friendship.RequesterId, friendship.ResponderId);
            return MapToResponse(friendship);
        }

        public async Task<bool> RejectFriendRequestAsync(int friendshipId, int responderId)
        {
            var friendship = await _context.Friendships.FirstOrDefaultAsync(f => f.Id == friendshipId && f.ResponderId == responderId);
            if (friendship == null) return false;
            if (friendship.Status != FriendshipStatus.Pending) throw new UserException("This friend request is not pending.");

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            ClearCache(friendship.RequesterId, friendship.ResponderId);
            return true;
        }

        public async Task<bool> UnfriendAsync(int friendshipId, int memberId)
        {
            var friendship = await _context.Friendships.FirstOrDefaultAsync(f => f.Id == friendshipId && 
                (f.RequesterId == memberId || f.ResponderId == memberId) && f.Status == FriendshipStatus.Accepted);
            if (friendship == null) return false;

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            ClearCache(friendship.RequesterId, friendship.ResponderId);
            return true;
        }

        public async Task<bool> CancelFriendRequestAsync(int friendshipId, int requesterId)
        {
            var friendship = await _context.Friendships.FirstOrDefaultAsync(f => f.Id == friendshipId && 
                f.RequesterId == requesterId && f.Status == FriendshipStatus.Pending);
            if (friendship == null) return false;

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            ClearCache(friendship.RequesterId, friendship.ResponderId);
            return true;
        }

        protected override FriendshipResponse MapToResponse(Friendship entity)
        {
            return new FriendshipResponse
            {
                Id = entity.Id, RequesterId = entity.RequesterId, ResponderId = entity.ResponderId,
                RequesterUsername = entity.Requester?.Username ?? string.Empty, RequesterFirstName = entity.Requester?.FirstName ?? string.Empty,
                RequesterLastName = entity.Requester?.LastName ?? string.Empty, RequesterProfilePictureUrl = entity.Requester?.ProfilePictureUrl ?? string.Empty,
                ResponderUsername = entity.Responder?.Username ?? string.Empty, ResponderFirstName = entity.Responder?.FirstName ?? string.Empty,
                ResponderLastName = entity.Responder?.LastName ?? string.Empty, ResponderProfilePictureUrl = entity.Responder?.ProfilePictureUrl ?? string.Empty,
                RequestedAt = entity.RequestedAt, RespondedAt = entity.RespondedAt, Status = entity.Status, StatusName = entity.Status.ToString()
            };
        }

        public async Task<List<FriendRecommendationResponse>> RecommendFriendsAsync(int userId, IEnumerable<int>? candidateUserIds = null, int topN = 5)
        {
            try
            {
                using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));
                return await RecommendFriendsInternalAsync(userId, candidateUserIds, topN, cts.Token);
            }
            catch (OperationCanceledException)
            {
                return await GetMostActiveMembersAsync(userId, topN);
            }
        }

        private async Task<List<FriendRecommendationResponse>> RecommendFriendsInternalAsync(int userId, IEnumerable<int>? candidateUserIds = null, int topN = 5, CancellationToken cancellationToken = default)
        {
            if (_cache.ContainsKey(userId) && DateTime.UtcNow - _cache[userId].Timestamp < _cacheExpiry)
            {
                return _cache[userId].Data.Take(topN).ToList();
            }

            var hasSufficientData = await HasSufficientActivityDataAsync(userId);
            if (!hasSufficientData)
            {
                var coldStart = await GetMostActiveMembersAsync(userId, topN);
                _cache[userId] = (coldStart, DateTime.UtcNow);
                return coldStart;
            }

            if (_model == null)
            {
                await TrainModelAsync();
                if (_model == null)
                {
                    return await GetMostActiveMembersAsync(userId, topN);
                }
            }

            var recommendations = await GenerateMLRecommendationsAsync(userId, candidateUserIds, topN);
            _cache[userId] = (recommendations, DateTime.UtcNow);
            return recommendations;
        }

        private async Task<List<FriendRecommendationResponse>> GenerateMLRecommendationsAsync(int userId, IEnumerable<int>? candidateUserIds, int topN)
        {
            var existingFriendships = await _context.Friendships.Where(f => f.RequesterId == userId || f.ResponderId == userId)
                .Select(f => new { f.RequesterId, f.ResponderId }).ToListAsync();
            var existingFriendIds = existingFriendships.Select(f => f.RequesterId == userId ? f.ResponderId : f.RequesterId).ToHashSet();

            var candidateIds = candidateUserIds?.ToList() ?? await _context.Members
                .Where(m => m.Id != userId && !existingFriendIds.Contains(m.Id)).Select(m => m.Id).ToListAsync();

            if (!candidateIds.Any()) return await GetMostActiveMembersAsync(userId, topN);

            var predictionEngine = GetPredictionEngine();
            if (predictionEngine == null) 
                return await GetMostActiveMembersAsync(userId, topN);
            
            var predictions = new List<(int UserId, float Score)>();

            foreach (var candidateId in candidateIds)
            {
                try
                {
                    var prediction = predictionEngine.Predict(new FriendData { UserId = userId, OtherUserId = candidateId, Label = 0 });
                    var activitySimilarity = await CalculateUserSimilarityAsync(userId, candidateId);
                    var finalScore = ClampScore((prediction.Score * 0.7f) + (activitySimilarity * 0.3f));
                    predictions.Add((candidateId, finalScore));
                }
                catch (Exception ex)
                {
                    var activitySimilarity = await CalculateUserSimilarityAsync(userId, candidateId);
                    predictions.Add((candidateId, ClampScore(activitySimilarity)));
                }
            }

            var topRecommendations = predictions.OrderByDescending(p => p.Score).Take(topN).ToList();
            var recommendedUserIds = topRecommendations.Select(p => p.UserId).ToList();
            var recommendedUsers = await _context.Members.Include(m => m.Troop).Where(m => recommendedUserIds.Contains(m.Id)).ToListAsync();

            return topRecommendations.Select(prediction =>
            {
                var user = recommendedUsers.FirstOrDefault(u => u.Id == prediction.UserId);
                return new FriendRecommendationResponse
                {
                    UserId = prediction.UserId, Username = user?.Username ?? string.Empty, FirstName = user?.FirstName ?? string.Empty,
                    LastName = user?.LastName ?? string.Empty, ProfilePictureUrl = user?.ProfilePictureUrl ?? string.Empty,
                    SimilarityScore = ClampScore(prediction.Score), TroopId = user?.TroopId ?? 0, TroopName = user?.Troop?.Name ?? string.Empty
                };
            }).ToList();
        }

        private async Task<float> CalculateUserSimilarityAsync(int userId, int otherUserId)
        {
            try
            {
                var interactions = await _context.Database.SqlQueryRaw<UserInteractionCounts>(@"
                    SELECT 
                        (SELECT COUNT(*) FROM ActivityRegistrations ar1 INNER JOIN ActivityRegistrations ar2 ON ar1.ActivityId = ar2.ActivityId 
                         WHERE ar1.MemberId = {0} AND ar2.MemberId = {1} AND ar1.Status = 1 AND ar2.Status = 1) as CommonActivities,
                        (SELECT COUNT(*) FROM Likes l1 INNER JOIN Likes l2 ON l1.PostId = l2.PostId 
                         WHERE l1.CreatedById = {0} AND l2.CreatedById = {1}) as SharedLikes,
                        (SELECT COUNT(*) FROM Comments c1 INNER JOIN Comments c2 ON c1.PostId = c2.PostId 
                         WHERE c1.CreatedById = {0} AND c2.CreatedById = {1}) as SharedComments,
                        (SELECT COUNT(*) FROM Likes l INNER JOIN Posts p ON l.PostId = p.Id 
                         WHERE l.CreatedById = {0} AND p.CreatedById = {1}) as DirectLikes,
                        (SELECT COUNT(*) FROM Likes l INNER JOIN Posts p ON l.PostId = p.Id 
                         WHERE l.CreatedById = {1} AND p.CreatedById = {0}) as ReciprocalLikes,
                        (SELECT COUNT(*) FROM Comments c INNER JOIN Posts p ON c.PostId = p.Id 
                         WHERE c.CreatedById = {0} AND p.CreatedById = {1}) as DirectComments,
                        (SELECT COUNT(*) FROM Comments c INNER JOIN Posts p ON c.PostId = p.Id 
                         WHERE c.CreatedById = {1} AND p.CreatedById = {0}) as ReciprocalComments,
                        (SELECT COUNT(*) FROM Reviews r1 INNER JOIN Reviews r2 ON r1.ActivityId = r2.ActivityId 
                         WHERE r1.MemberId = {0} AND r2.MemberId = {1}) as CommonReviews",
                    userId, otherUserId).FirstOrDefaultAsync();

                return CalculateWeightedScore(interactions);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error calculating similarity for users {User1} and {User2}", userId, otherUserId);
                return 0.1f;
            }
        }

        private float CalculateWeightedScore(UserInteractionCounts? interactions)
        {
            if (interactions == null) return 0.1f;

            var totalInteractions = (interactions.CommonActivities * 3.0f) + (interactions.SharedLikes * 1.5f) +
                (interactions.SharedComments * 2.0f) + ((interactions.DirectLikes + interactions.ReciprocalLikes) * 3.0f) +
                ((interactions.DirectComments + interactions.ReciprocalComments) * 4.0f) + (interactions.CommonReviews * 4.0f);

            return ClampScore(0.1f + Math.Min(totalInteractions / 20.0f, 0.9f));
        }

        private async Task<List<FriendRecommendationResponse>> GetMostActiveMembersAsync(int userId, int topN = 5)
        {
            var existingFriendships = await _context.Friendships.Where(f => f.RequesterId == userId || f.ResponderId == userId)
                .Select(f => new { f.RequesterId, f.ResponderId }).ToListAsync();
            var existingFriendIds = existingFriendships.Select(f => f.RequesterId == userId ? f.ResponderId : f.RequesterId).ToHashSet();

            var memberActivityScores = await _context.Members.Where(m => m.Id != userId && !existingFriendIds.Contains(m.Id))
                .Select(m => new { Member = m, ActivityScore = _context.ActivityRegistrations.Where(ar => ar.MemberId == m.Id && ar.Status == RegistrationStatus.Approved).Count() * 2.0f +
                    _context.Posts.Where(p => p.CreatedById == m.Id).Count() * 1.5f + _context.Comments.Where(c => c.CreatedById == m.Id).Count() * 1.0f +
                    _context.Likes.Where(l => l.CreatedById == m.Id).Count() * 0.5f + _context.Reviews.Where(r => r.MemberId == m.Id).Count() * 2.0f })
                .OrderByDescending(x => x.ActivityScore).Take(topN).ToListAsync();

            return memberActivityScores.Select(x => new FriendRecommendationResponse
            {
                UserId = x.Member.Id, Username = x.Member.Username, FirstName = x.Member.FirstName, LastName = x.Member.LastName,
                ProfilePictureUrl = x.Member.ProfilePictureUrl, SimilarityScore = ClampScore(Math.Min(0.1f + (x.ActivityScore / 30.0f), 0.8f)),
                TroopId = x.Member.TroopId, TroopName = x.Member.Troop?.Name ?? string.Empty
            }).ToList();
        }

        private async Task<bool> HasSufficientActivityDataAsync(int userId)
        {
            var activityCount = await _context.ActivityRegistrations.Where(ar => ar.MemberId == userId && ar.Status == RegistrationStatus.Approved).CountAsync();
            var totalInteractions = activityCount + await _context.Posts.Where(p => p.CreatedById == userId).CountAsync() +
                await _context.Comments.Where(c => c.CreatedById == userId).CountAsync() + await _context.Likes.Where(l => l.CreatedById == userId).CountAsync() +
                await _context.Reviews.Where(r => r.MemberId == userId).CountAsync();
            return activityCount >= 3 || totalInteractions >= 5;
        }

        public async Task TrainModelAsync(IEnumerable<FriendData>? trainingData = null)
        {
            try
            {
                var data = trainingData?.ToList() ?? await GenerateTrainingDataAsync();
                if (!data.Any()) { return; }

                var (iterations, rank) = GetOptimalTrainingParams();
                _logger.LogInformation($"Training ML model with {iterations} iterations and rank {rank} for {data.Count} training samples");

                var dataView = _mlContext.Data.LoadFromEnumerable(data);
                var pipeline = _mlContext.Transforms.Conversion.MapValueToKey("UserIdEncoded", "UserId")
                    .Append(_mlContext.Transforms.Conversion.MapValueToKey("OtherUserIdEncoded", "OtherUserId"))
                    .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                        labelColumnName: "Label", 
                        matrixColumnIndexColumnName: "UserIdEncoded", 
                        matrixRowIndexColumnName: "OtherUserIdEncoded",
                        numberOfIterations: iterations, 
                        approximationRank: rank,
                        learningRate: 0.1f));

                _model = pipeline.Fit(dataView);
                await SaveModelAsync();
                _logger.LogInformation($"ML model training completed successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error training ML model");
                throw;
            }
        }

        private async Task<List<FriendData>> GenerateTrainingDataAsync()
        {
            var interactingUsers = await _context.Database.SqlQueryRaw<int>(@"
                SELECT DISTINCT m1.Id FROM Members m1
                WHERE EXISTS (SELECT 1 FROM Posts p WHERE p.CreatedById = m1.Id)
                   OR EXISTS (SELECT 1 FROM ActivityRegistrations ar WHERE ar.MemberId = m1.Id)
                   OR EXISTS (SELECT 1 FROM Likes l WHERE l.CreatedById = m1.Id)
                LIMIT 500
            ").ToListAsync();

            var trainingData = new List<FriendData>();
            
            foreach (var user1 in interactingUsers)
            {
                var potentialConnections = await _context.Database.SqlQueryRaw<int>(@"
                    SELECT DISTINCT 
                        CASE WHEN f.RequesterId = {0} THEN f.ResponderId ELSE f.RequesterId END as ConnectedUserId
                    FROM Friendships f 
                    WHERE (f.RequesterId = {0} OR f.ResponderId = {0}) AND f.Status = 1
                    UNION
                    SELECT DISTINCT ar2.MemberId 
                    FROM ActivityRegistrations ar1 
                    INNER JOIN ActivityRegistrations ar2 ON ar1.ActivityId = ar2.ActivityId 
                    WHERE ar1.MemberId = {0} AND ar2.MemberId != {0}
                    LIMIT 50
                ", user1).ToListAsync();
                
                foreach (var user2 in potentialConnections.Take(20))
                {
                    var similarity = await CalculateUserSimilarityAsync(user1, user2);
                    trainingData.Add(new FriendData { 
                        UserId = user1, 
                        OtherUserId = user2, 
                        Label = Math.Max(0.01f, similarity)
                    });
                }
            }
            
            return trainingData;
        }

        private async Task SaveModelAsync()
        {
            if (_model == null) return;
            var directory = Path.GetDirectoryName(_modelPath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory)) Directory.CreateDirectory(directory);
            await Task.Run(() => _mlContext.Model.Save(_model, null, _modelPath));
        }

        private void LoadModelIfExists()
        {
            try
            {
                if (File.Exists(_modelPath))
                {
                    _model = _mlContext.Model.Load(_modelPath, out var modelInputSchema);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading model from {ModelPath}", _modelPath);
            }
        }

        private PredictionEngine<FriendData, FriendPrediction>? GetPredictionEngine()
        {
            lock (_predictionEngineLock)
            {
                if (_cachedPredictionEngine == null || DateTime.Now - _lastPredictionEngineCreation > _predictionEngineLifetime)
                {
                    _cachedPredictionEngine?.Dispose();
                    _cachedPredictionEngine = _model != null
                        ? _mlContext.Model.CreatePredictionEngine<FriendData, FriendPrediction>(_model)
                        : null;
                    _lastPredictionEngineCreation = DateTime.Now;
                }
                return _cachedPredictionEngine;
            }
        }

        private (int iterations, int rank) GetOptimalTrainingParams()
        {
            var userCount = _context.Members.Count();
            return userCount switch
            {
                < 100 => (30, 8),
                < 500 => (40, 16),
                < 2000 => (50, 32),
                < 10000 => (60, 64),
                _ => (80, 128)
            };
        }

        public async Task RetrainModelAsync()
        {
            lock (_predictionEngineLock)
            {
                _model = null;
                _cachedPredictionEngine = null;
            }
            await TrainModelAsync();
        }

        public void ClearRecommendationCache(int? userId = null)
        {
            if (userId.HasValue)
            {
                _cache.Remove(userId.Value);
            }
            else
            {
                _cache.Clear();
            }
        }

        public async Task WarmUpCacheAsync(int maxUsers = 50)
        {
            try
            {
                var activeUsers = await _context.Members
                    .Select(m => new { m.Id, ActivityScore = (m.ActivityRegistrations.Count(ar => ar.Status == RegistrationStatus.Approved)) * 2.0f +
                        m.Posts.Count() * 1.5f + m.Comments.Count() * 1.0f + m.Likes.Count() * 0.5f + m.Reviews.Count() * 1.2f })
                    .OrderByDescending(x => x.ActivityScore).Take(maxUsers).Select(x => x.Id).ToListAsync();

                var warmUpTasks = activeUsers.Select(async userId =>
                {
                    try { await RecommendFriendsInternalAsync(userId, null, 5, CancellationToken.None); }
                    catch (Exception ex) { _logger.LogWarning(ex, "Failed to warm up cache for user {UserId}", userId); }
                });

                await Task.WhenAll(warmUpTasks);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during cache warm-up");
            }
        }

        public object GetCacheStatistics()
        {
            var now = DateTime.UtcNow;
            var expiredCount = _cache.Count(kvp => now - kvp.Value.Timestamp > _cacheExpiry);
            return new
            {
                TotalCachedUsers = _cache.Count,
                ActiveCacheEntries = _cache.Count - expiredCount,
                ExpiredCacheEntries = expiredCount,
                CacheExpiryMinutes = _cacheExpiry.TotalMinutes
            };
        }

        private void ClearCache(int userId1, int userId2)
        {
            _cache.Remove(userId1);
            _cache.Remove(userId2);
        }

        private static float ClampScore(float score)
        {
            if (float.IsNaN(score) || float.IsInfinity(score)) return 0.0f;
            return Math.Max(0.0f, Math.Min(1.0f, score));
        }
    }
}