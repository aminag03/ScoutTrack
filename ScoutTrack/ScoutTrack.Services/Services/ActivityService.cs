using Azure;
using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services.ActivityStateMachine;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class ActivityService : BaseCRUDService<ActivityResponse, ActivitySearchObject, Activity, ActivityUpsertRequest, ActivityUpsertRequest>, IActivityService
    {
        private readonly ScoutTrackDbContext _context;
        protected readonly BaseActivityState _baseActivityState;
        private readonly ILogger<MemberService> _logger;
        private readonly IWebHostEnvironment _env;
        private readonly IAccessControlService _accessControlService;
        
        private readonly MLContext _mlContext;
        
        private ITransformer? _globalActivityModel;
        private readonly string _globalModelPath = Path.Combine("Models", "GlobalActivityModel.zip");
        private readonly object _globalModelLock = new object();
        
        private readonly Dictionary<int, PredictionEngine<ActivityFeatures, ActivityPrediction>> _predictionEngines = new();
        private readonly object _predictionEngineLock = new object();
        
        private readonly IMemoryCache _recommendationCache;
        private readonly TimeSpan _cacheDuration = TimeSpan.FromMinutes(30);

        public ActivityService(ScoutTrackDbContext context, IMapper mapper, BaseActivityState baseActivityState, ILogger<MemberService> logger, IWebHostEnvironment env, IAccessControlService accessControlService, IMemoryCache recommendationCache) : base(context, mapper)
        {
            _context = context;
            _baseActivityState = baseActivityState;
            _logger = logger;
            _env = env;
            _accessControlService = accessControlService;
            _recommendationCache = recommendationCache;
            _mlContext = new MLContext(seed: 0);
        }

        public override async Task<PagedResult<ActivityResponse>> GetAsync(ActivitySearchObject search)
        {
            var query = _context.Set<Activity>()
                .Include(a => a.Registrations)
                .AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                if (search.OrderBy.StartsWith("-"))
                {
                    query = query.OrderByDescendingDynamic(search.OrderBy[1..]);
                }
                else
                {
                    query = query.OrderByDynamic(search.OrderBy);
                }
            }

            var entities = await query.ToListAsync();
            var responseList = entities.Select(MapToResponse).ToList();

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;

                if (orderBy.Equals("memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderBy(x => x.RegistrationCount).ToList();
                }
                else if (orderBy.Equals("-memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderByDescending(x => x.RegistrationCount).ToList();
                }
                else
                {
                    bool descending = false;
                    if (orderBy.StartsWith("-"))
                    {
                        descending = true;
                        orderBy = orderBy[1..];
                    }

                    responseList = orderBy.ToLower() switch
                    {
                        "title" => descending
                            ? responseList.OrderByDescending(x => x.Title).ToList()
                            : responseList.OrderBy(x => x.Title).ToList(),

                        "starttime" => descending
                            ? responseList.OrderByDescending(x => x.StartTime).ToList()
                            : responseList.OrderBy(x => x.StartTime).ToList(),

                        "endtime" => descending
                            ? responseList.OrderByDescending(x => x.EndTime).ToList()
                            : responseList.OrderBy(x => x.EndTime).ToList(),

                        _ => responseList
                    };
                }
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    responseList = responseList
                        .Skip(search.Page.Value * search.PageSize.Value)
                        .Take(search.PageSize.Value)
                        .ToList();
                }
            }

            return new PagedResult<ActivityResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Activity> ApplyFilter(IQueryable<Activity> query, ActivitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(a => a.Title.Contains(search.Title));
            }
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => a.Title.Contains(search.FTS) || a.Description.Contains(search.FTS));
            }
            if (search.TroopId.HasValue)
            {
                query = query.Where(a => a.TroopId == search.TroopId.Value);
            }
            if (search.ActivityTypeId.HasValue)
            {
                query = query.Where(a => a.ActivityTypeId == search.ActivityTypeId.Value);
            }
            if (search.IsPrivate.HasValue)
            {
                query = query.Where(a => a.isPrivate == search.IsPrivate.Value);
            }
            if (!string.IsNullOrEmpty(search.ActivityState))
            {
                query = query.Where(a => a.ActivityState == search.ActivityState);
            }
            if (search.ExcludeStates != null && search.ExcludeStates.Any())
            {
                query = query.Where(a => !search.ExcludeStates.Contains(a.ActivityState));
            }
            if (search.ShowPublicAndOwn.HasValue && search.ShowPublicAndOwn.Value && search.OwnTroopId.HasValue)
            {
                query = query.Where(a => 
                    (!a.isPrivate || a.TroopId == search.OwnTroopId.Value) && 
                    (a.ActivityState != "DraftActivityState" || a.TroopId == search.OwnTroopId.Value) &&
                    (a.ActivityState != "CancelledActivityState" || a.TroopId == search.OwnTroopId.Value));
            }

            query = query.Include(a => a.Troop);
            query = query.Include(a => a.ActivityType);

            return query;
        }

        public override async Task<ActivityResponse> CreateAsync(ActivityUpsertRequest request)
        {
            var baseState = _baseActivityState.GetActivityState(nameof(InitialActivityState));

            var entity = new Activity();
            _mapper.Map(request, entity);
            await BeforeInsert(entity, request);

            var result = await baseState.CreateAsync(request);
            return result;

            // return await base.CreateAsync(request);
        }

        public override async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            _mapper.Map(request, entity);
            await BeforeUpdate(entity, request);

            return await baseState.UpdateAsync(id, request);
            // return await base.UpdateAsync(id, request);
        }

        public override async Task<ActivityResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .Include(a => a.Registrations)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");

            return await baseState.UpdateAsync(id, request);
        }

        public async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request, int currentUserId)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");

            return await baseState.UpdateAsync(id, request, currentUserId);
        }

        protected override async Task BeforeInsert(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        protected override async Task BeforeUpdate(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        protected override async Task BeforeDelete(Activity entity)
        {
            var posts = await _context.Posts
                .Include(p => p.Images)
                .Include(p => p.Likes)
                .Include(p => p.Comments)
                .Where(p => p.ActivityId == entity.Id)
                .ToListAsync();
            
            if (posts.Any())
            {
                foreach (var post in posts)
                {
                    if (post.Likes.Any())
                    {
                        _context.Likes.RemoveRange(post.Likes);
                    }
                    
                    if (post.Comments.Any())
                    {
                        _context.Comments.RemoveRange(post.Comments);
                    }
                    
                    if (post.Images.Any())
                    {
                        foreach (var image in post.Images)
                        {
                            try
                            {
                                string relativePath;
                                if (image.ImageUrl.StartsWith("http"))
                                {
                                    var uri = new Uri(image.ImageUrl);
                                    relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                                }
                                else
                                {
                                    relativePath = image.ImageUrl.Replace('/', Path.DirectorySeparatorChar);
                                }
                                
                                var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                                if (File.Exists(fullPath))
                                    File.Delete(fullPath);
                            }
                            catch (Exception ex)
                            {
                                _logger.LogWarning(ex, "Error while deleting post image file: {imageUrl}", image.ImageUrl);
                            }
                        }
                        _context.PostImages.RemoveRange(post.Images);
                    }
                    
                    _context.Posts.Remove(post);
                }
            }

            var registrations = await _context.ActivityRegistrations
                .Where(ar => ar.ActivityId == entity.Id)
                .ToListAsync();
            
            if (registrations.Any())
            {
                _context.ActivityRegistrations.RemoveRange(registrations);
            }

            var reviews = await _context.Reviews
                .Where(r => r.ActivityId == entity.Id)
                .ToListAsync();

            if (reviews.Any())
            {
                _context.Reviews.RemoveRange(reviews);
            }

            if (!string.IsNullOrWhiteSpace(entity.ImagePath))
            {
                try
                {
                    string relativePath;
                    if (entity.ImagePath.StartsWith("http"))
                    {
                        var uri = new Uri(entity.ImagePath);
                        relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ImagePath.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting activity image from file system.");
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task<ActivityResponse> ActivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.ActivateAsync(id);
        }

        public async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.DeactivateAsync(id);
        }

        public async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found.");

            var state = _baseActivityState.GetActivityState(entity.ActivityState);

            if (state is not RegistrationsOpenActivityState activeState)
            {
                throw new UserException($"Registrations can only be closed while active. Current state: {entity.ActivityState}");
            }

            var result = await activeState.CloseRegistrationsAsync(id);            
            return result;
        }

        public async Task<ActivityResponse> FinishAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found.");


            var state = _baseActivityState.GetActivityState(entity.ActivityState);

            if (state is not RegistrationsClosedActivityState registrationsClosedState)
            {
                throw new UserException($"You can only finish an activity after closing registrations. Current state: {entity.ActivityState}");
            }

            //if (entity.EndTime.HasValue && entity.EndTime > DateTime.Now)
                //throw new UserException("You can't finish the activity before it's scheduled to end.");

            var result = await registrationsClosedState.FinishAsync(id);

            return result;
        }

        public async Task<ActivityResponse?> UpdateImageAsync(int id, string? imagePath)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            if (!string.IsNullOrWhiteSpace(entity.ImagePath))
            {
                try
                {
                    string relativePath;
                    if (entity.ImagePath.StartsWith("http"))
                    {
                        var oldUri = new Uri(entity.ImagePath);
                        relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ImagePath.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting old image");
                }
            }

            entity.ImagePath = string.IsNullOrWhiteSpace(imagePath) ? "" : imagePath;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            var updatedEntity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (updatedEntity == null)
                return null;

            return MapToResponse(updatedEntity);
        }

        public async Task<ActivityResponse?> UpdateSummaryAsync(int id, string summary)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            entity.Summary = summary;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            var updatedEntity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (updatedEntity == null)
                return null;

            return MapToResponse(updatedEntity);
        }

        public async Task<ActivityResponse?> TogglePrivacyAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            entity.isPrivate = !entity.isPrivate;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            var updatedEntity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (updatedEntity == null)
                return null;

            return MapToResponse(updatedEntity);
        }

        public async Task<ActivityResponse?> ReactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            if (entity.ActivityState != nameof(CancelledActivityState))
            {
                throw new UserException("Only cancelled activities can be reactivated.");
            }

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);
            
            if (baseState is CancelledActivityState cancelledState)
            {
                return await cancelledState.ReactivateAsync(id);
            }

            throw new UserException("Invalid state for reactivation.");
        }

        public async Task<bool> CleanupPendingAndRejectedRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found.");

            if (entity.ActivityState != "FinishedActivityState")
            {
                throw new UserException("Can only cleanup registrations for finished activities.");
            }

            var registrationsToDelete = await _context.ActivityRegistrations
                .Where(ar => ar.ActivityId == id && (ar.Status == Common.Enums.RegistrationStatus.Pending 
                || ar.Status == Common.Enums.RegistrationStatus.Rejected))
                .ToListAsync();

            if (registrationsToDelete.Any())
            {
                _context.ActivityRegistrations.RemoveRange(registrationsToDelete);
                await _context.SaveChangesAsync();
            }

            return true;
        }

        protected override ActivityResponse MapToResponse(Activity entity)
        {
            var completedCount = entity.Registrations?.Count(r => r.Status == Common.Enums.RegistrationStatus.Completed) ?? 0;
            var pendingCount = entity.Registrations?.Count(r => r.Status == Common.Enums.RegistrationStatus.Pending) ?? 0;
            var approvedCount = entity.Registrations?.Count(r => r.Status == Common.Enums.RegistrationStatus.Approved) ?? 0;

            return new ActivityResponse
            {
                Id = entity.Id,
                Title = entity.Title,
                Description = entity.Description,
                Summary = entity.Summary,
                isPrivate = entity.isPrivate,
                StartTime = entity.StartTime,
                EndTime = entity.EndTime,
                Latitude = entity.Latitude,
                Longitude = entity.Longitude,
                LocationName = entity.LocationName,
                Fee = entity.Fee,
                TroopId = entity.TroopId,
                TroopName = entity.Troop?.Name ?? string.Empty,
                ActivityTypeId = entity.ActivityTypeId,
                ActivityTypeName = entity.ActivityType?.Name ?? string.Empty,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ActivityState = entity.ActivityState,
                RegistrationCount = completedCount,
                PendingRegistrationCount = pendingCount,
                ApprovedRegistrationCount = approvedCount,
                ImagePath = entity.ImagePath,
            };
        }

        public async Task<PagedResult<ActivityResponse>> GetForUserAsync(ClaimsPrincipal user, ActivitySearchObject search)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole == "Member")
            {
                var member = await _context.Members
                    .FirstOrDefaultAsync(m => m.Id == userId);
                
                if (member != null)
                {
                    search.ShowPublicAndOwn = true;
                    search.OwnTroopId = member.TroopId;
                    search.ExcludeStates = new List<string> { "DraftActivityState", "CancelledActivityState" };
                }
            }
            else if (userRole == "Troop")
            {
                search.ShowPublicAndOwn = true;
                search.OwnTroopId = userId;
            }

            return await GetAsync(search);
        }

        public async Task<ActivityResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanViewActivityAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to view this activity.");
            }

            var activity = await GetByIdAsync(id);
            if (activity == null)
                return null;

            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole == "Member")
            {
                if (activity.ActivityState == "DraftActivityState" || activity.ActivityState == "CancelledActivityState")
                {
                    throw new UnauthorizedAccessException("You do not have permission to view this activity.");
                }
            }
            else if (userRole == "Troop")
            {
                if (activity.isPrivate && activity.TroopId != userId)
                {
                    throw new UnauthorizedAccessException("You do not have permission to view this private activity.");
                }
            }

            return activity;
        }

        public async Task<List<ActivityResponse>> GetActivitiesByMemberAsync(int memberId)
        {
            var activities = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .Include(a => a.Registrations)
                .Where(a => a.Registrations
                    .Any(ar => ar.MemberId == memberId && ar.Status == Common.Enums.RegistrationStatus.Completed))
                .Where(a => a.ActivityState != "DraftActivityState" && a.ActivityState != "CancelledActivityState")
                .OrderByDescending(a => a.StartTime)
                .ToListAsync();

            return activities.Select(MapToResponse).ToList();
        }

        public async Task<List<ActivityResponse>> GetActivitiesByTroopAsync(int troopId)
        {
            var activities = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .Include(a => a.Registrations)
                .Where(a => a.TroopId == troopId)
                .Where(a => a.ActivityState != "DraftActivityState" && a.ActivityState != "CancelledActivityState")
                .OrderByDescending(a => a.StartTime)
                .ToListAsync();

            return activities.Select(MapToResponse).ToList();
        }

        public async Task<ActivityResponse?> GetEarliestUpcomingActivityForMemberAsync(int memberId)
        {
            var registrations = await _context.ActivityRegistrations
                .Where(r => r.MemberId == memberId && 
                           (r.Status == Common.Enums.RegistrationStatus.Pending || 
                            r.Status == Common.Enums.RegistrationStatus.Approved))
                .Select(r => r.ActivityId)
                .ToListAsync();

            if (!registrations.Any())
            {
                return null;
            }

            var activity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .Include(a => a.Registrations)
                .Where(a => registrations.Contains(a.Id))
                .Where(a => a.ActivityState == "RegistrationsOpenActivityState" || 
                           a.ActivityState == "RegistrationsClosedActivityState")
                .Where(a => a.StartTime.HasValue && a.StartTime > DateTime.Now)
                .OrderBy(a => a.StartTime)
                .FirstOrDefaultAsync();

            return activity != null ? MapToResponse(activity) : null;
        }

        public async Task<List<ActivityResponse>> GetRecommendedActivitiesForMemberAsync(int memberId, int topN = 10)
        {
            var cacheKey = $"activity_recs_{memberId}";
            if (_recommendationCache.TryGetValue(cacheKey, out List<ActivityResponse> cached))
            {
                return cached.Take(topN).ToList();
            }

            var member = await _context.Members
                .Include(m => m.City)
                .FirstOrDefaultAsync(m => m.Id == memberId);

            if (member == null)
            {
                return new List<ActivityResponse>();
            }

            await LoadOrTrainGlobalModelAsync();
            
            if (_globalActivityModel == null)
            {
                return await GetPopularActivitiesAsync(topN);
            }

            var interactedActivityIds = await _context.ActivityRegistrations
                .Where(r => r.MemberId == memberId)
                .Select(r => r.ActivityId)
                .Union(_context.Reviews
                    .Where(r => r.MemberId == memberId)
                    .Select(r => r.ActivityId))
                .ToListAsync();
            
            var candidateActivities = await _context.Activities
                .Include(a => a.ActivityType)
                .Include(a => a.Troop)
                .Include(a => a.Registrations)
                .Where(a => !interactedActivityIds.Contains(a.Id))
                .Where(a => a.ActivityState == "RegistrationsOpenActivityState")
                .Where(a => !a.isPrivate || a.TroopId == member.TroopId)
                .AsNoTracking()
                .ToListAsync();

            var candidateIds = candidateActivities.Select(a => a.Id).ToList();

            if (!candidateActivities.Any())
            {
                return new List<ActivityResponse>();
            }

            var userPreferences = await GetUserActivityPreferences(memberId);
            var predictionEngine = GetPredictionEngine(_globalActivityModel);

            var predictions = new List<(ActivityResponse Activity, float Score)>();

            foreach (var activity in candidateActivities)
            {
                var duration = activity.EndTime.HasValue && activity.StartTime.HasValue
                    ? (float)(activity.EndTime.Value - activity.StartTime.Value).TotalHours
                    : 24.0f;

                var month = activity.StartTime?.Month ?? DateTime.Now.Month;

                var input = new ActivityFeatures
                {
                    Latitude = (float)activity.Latitude,
                    Longitude = (float)activity.Longitude,
                    ActivityTypeId = (float)activity.ActivityTypeId,
                    TroopId = (float)activity.TroopId,
                    Fee = (float)(activity.Fee ?? 0),
                    DurationHours = duration,
                    MonthOfYear = (float)month
                };

                var globalScore = predictionEngine.Predict(input).Score;
                var personalScore = CalculatePersonalPreference(userPreferences, activity);
                var finalScore = (globalScore * 0.6f) + (personalScore * 0.4f);
                predictions.Add((MapToResponse(activity), finalScore));
            }

            var recommendations = predictions
                .OrderByDescending(p => p.Score)
                .Take(topN)
                .Select(p => p.Activity)
                .ToList();

            _recommendationCache.Set(cacheKey, recommendations, _cacheDuration);
            return recommendations;
        }

        private async Task<List<ActivityResponse>> GetPopularActivitiesAsync(int topN)
        {
            var popularActivities = await _context.Activities
                .Include(a => a.ActivityType)
                .Include(a => a.Troop)
                .Include(a => a.Registrations)
                .Where(a => a.ActivityState == "RegistrationsOpenActivityState")
                .Where(a => !a.isPrivate)
                .OrderByDescending(a => a.Registrations.Count)
                .Take(topN)
                .ToListAsync();

            return popularActivities.Select(MapToResponse).ToList();
        }

        public void RetrainModelForMember(int memberId)
        {
            lock (_globalModelLock)
            {
                _globalActivityModel = null;
            }
            
            if (File.Exists(_globalModelPath))
            {
                File.Delete(_globalModelPath);
            }
            
            var cacheKey = $"activity_recs_{memberId}";
            _recommendationCache.Remove(cacheKey);
        }

        private PredictionEngine<ActivityFeatures, ActivityPrediction> GetPredictionEngine(ITransformer model)
        {
            lock (_predictionEngineLock)
            {
                var modelHash = model.GetHashCode();
                if (!_predictionEngines.ContainsKey(modelHash))
                {
                    _predictionEngines[modelHash] = _mlContext.Model
                        .CreatePredictionEngine<ActivityFeatures, ActivityPrediction>(model);
                }
                return _predictionEngines[modelHash];
            }
        }

        private async Task LoadOrTrainGlobalModelAsync()
        {
            lock (_globalModelLock)
            {
                if (_globalActivityModel != null)
                    return;
            }

            if (File.Exists(_globalModelPath))
            {
                lock (_globalModelLock)
                {
                    _globalActivityModel = _mlContext.Model.Load(_globalModelPath, out _);
                }
            }
            else
            {
                var model = await TrainGlobalModelAsync();
                lock (_globalModelLock)
                {
                    _globalActivityModel = model;
                }
                var modelDir = Path.GetDirectoryName(_globalModelPath);
                if (!string.IsNullOrEmpty(modelDir) && !Directory.Exists(modelDir))
                {
                    Directory.CreateDirectory(modelDir);
                }
                _mlContext.Model.Save(_globalActivityModel, null, _globalModelPath);
            }
        }

        private async Task<ITransformer> TrainGlobalModelAsync()
        {
            var allTrainingData = await PrepareGlobalTrainingDataAsync();
            
            if (!allTrainingData.Any())
            {
                throw new InvalidOperationException("Cannot train global model without training data");
            }

            var dataView = _mlContext.Data.LoadFromEnumerable(allTrainingData);
            
            var pipeline = _mlContext.Transforms.Concatenate("Features",
                    nameof(ActivityFeatures.Latitude),
                    nameof(ActivityFeatures.Longitude),
                    nameof(ActivityFeatures.ActivityTypeId),
                    nameof(ActivityFeatures.TroopId),
                    nameof(ActivityFeatures.Fee),
                    nameof(ActivityFeatures.DurationHours),
                    nameof(ActivityFeatures.MonthOfYear))
                .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
                .Append(_mlContext.Regression.Trainers.Sdca(
                    labelColumnName: nameof(ActivityFeatures.Label),
                    featureColumnName: "Features",
                    maximumNumberOfIterations: 100));

            var model = pipeline.Fit(dataView);
            
            var predictions = model.Transform(dataView);
            var metrics = _mlContext.Regression.Evaluate(predictions, labelColumnName: nameof(ActivityFeatures.Label));

            return model;
        }

        private async Task<List<ActivityFeatures>> PrepareGlobalTrainingDataAsync()
        {
            var trainingData = new List<ActivityFeatures>();

            var completedRegistrations = await _context.ActivityRegistrations
                .Where(r => r.Status == Common.Enums.RegistrationStatus.Completed)
                .Include(r => r.Activity)
                    .ThenInclude(a => a.ActivityType)
                .Include(r => r.Activity)
                    .ThenInclude(a => a.Troop)
                .AsNoTracking()
                .ToListAsync();

            foreach (var registration in completedRegistrations)
            {
                var activity = registration.Activity;
                var duration = activity.EndTime.HasValue && activity.StartTime.HasValue
                    ? (float)(activity.EndTime.Value - activity.StartTime.Value).TotalHours
                    : 24.0f;

                var month = activity.StartTime?.Month ?? DateTime.Now.Month;

                trainingData.Add(new ActivityFeatures
                {
                    Latitude = (float)activity.Latitude,
                    Longitude = (float)activity.Longitude,
                    ActivityTypeId = (float)activity.ActivityTypeId,
                    TroopId = (float)activity.TroopId,
                    Fee = (float)(activity.Fee ?? 0),
                    DurationHours = duration,
                    MonthOfYear = (float)month,
                    Label = 1.0f
                });
            }

            var highRatedReviews = await _context.Reviews
                .Where(r => r.Rating >= 4)
                .Include(r => r.Activity)
                    .ThenInclude(a => a.ActivityType)
                .Include(r => r.Activity)
                    .ThenInclude(a => a.Troop)
                .AsNoTracking()
                .ToListAsync();

            foreach (var review in highRatedReviews)
            {
                var activity = review.Activity;
                var duration = activity.EndTime.HasValue && activity.StartTime.HasValue
                    ? (float)(activity.EndTime.Value - activity.StartTime.Value).TotalHours
                    : 24.0f;

                var month = activity.StartTime?.Month ?? DateTime.Now.Month;

                trainingData.Add(new ActivityFeatures
                {
                    Latitude = (float)activity.Latitude,
                    Longitude = (float)activity.Longitude,
                    ActivityTypeId = (float)activity.ActivityTypeId,
                    TroopId = (float)activity.TroopId,
                    Fee = (float)(activity.Fee ?? 0),
                    DurationHours = duration,
                    MonthOfYear = (float)month,
                    Label = review.Rating / 5.0f
                });
            }

            return trainingData;
        }

        public class ActivityFeatures
        {
            [LoadColumn(0)]
            public float Latitude { get; set; }

            [LoadColumn(1)]
            public float Longitude { get; set; }

            [LoadColumn(2)]
            public float ActivityTypeId { get; set; }

            [LoadColumn(3)]
            public float TroopId { get; set; }

            [LoadColumn(4)]
            public float Fee { get; set; }

            [LoadColumn(5)]
            public float DurationHours { get; set; }

            [LoadColumn(6)]
            public float MonthOfYear { get; set; }

            [LoadColumn(7)]
            public float Label { get; set; }
        }

        public class ActivityPrediction
        {
            public float Score { get; set; }
        }

        private async Task<UserActivityPreferences> GetUserActivityPreferences(int memberId)
        {
            var completedActivities = await _context.ActivityRegistrations
                .Where(r => r.MemberId == memberId && r.Status == Common.Enums.RegistrationStatus.Completed)
                .Include(r => r.Activity).ThenInclude(a => a.ActivityType)
                .Select(r => r.Activity).ToListAsync();

            var highRatedReviews = await _context.Reviews
                .Where(r => r.MemberId == memberId && r.Rating >= 4)
                .Include(r => r.Activity).ThenInclude(a => a.ActivityType)
                .Select(r => new { r.Activity, r.Rating }).ToListAsync();

            var preferredActivityTypes = completedActivities.Concat(highRatedReviews.Select(r => r.Activity))
                .GroupBy(a => a.ActivityTypeId)
                .OrderByDescending(g => g.Count())
                .Take(3)
                .Select(g => g.Key)
                .ToList();

            var activitiesWithFee = completedActivities.Where(a => a.Fee.HasValue).ToList();
            var activitiesWithDuration = completedActivities
                .Where(a => a.StartTime.HasValue && a.EndTime.HasValue)
                .ToList();

            var avgFee = activitiesWithFee.Any() ? activitiesWithFee.Average(a => a.Fee.Value) : 0;
            var avgDuration = activitiesWithDuration.Any() 
                ? activitiesWithDuration.Average(a => (a.EndTime.Value - a.StartTime.Value).TotalHours) 
                : 0;

            return new UserActivityPreferences
            {
                PreferredActivityTypeIds = preferredActivityTypes,
                PreferredAvgFee = (float)avgFee,
                PreferredAvgDuration = (float)avgDuration,
                PreferredLocationLat = completedActivities.Any() ? (float)completedActivities.Average(a => a.Latitude) : 0,
                PreferredLocationLon = completedActivities.Any() ? (float)completedActivities.Average(a => a.Longitude) : 0
            };
        }

        private float CalculatePersonalPreference(UserActivityPreferences preferences, Activity activity)
        {
            float score = 0.5f;

            if (preferences.PreferredActivityTypeIds.Contains(activity.ActivityTypeId))
                score += 0.4f;

            if (activity.Fee.HasValue && preferences.PreferredAvgFee > 0)
            {
                var feeDiff = Math.Abs((float)activity.Fee.Value - preferences.PreferredAvgFee) / preferences.PreferredAvgFee;
                score += Math.Max(0, 0.2f - feeDiff);
            }

            if (activity.StartTime.HasValue && activity.EndTime.HasValue && preferences.PreferredAvgDuration > 0)
            {
                var duration = (activity.EndTime.Value - activity.StartTime.Value).TotalHours;
                var durationDiff = Math.Abs(duration - preferences.PreferredAvgDuration) / preferences.PreferredAvgDuration;
                score += Math.Max(0, 0.2f - (float)durationDiff);
            }

            if (preferences.PreferredLocationLat != 0 && preferences.PreferredLocationLon != 0)
            {
                var distance = Math.Sqrt(Math.Pow(activity.Latitude - preferences.PreferredLocationLat, 2) + Math.Pow(activity.Longitude - preferences.PreferredLocationLon, 2));
                score += Math.Max(0, 0.2f - (float)(distance / 100.0));
            }

            return Math.Min(1.0f, score);
        }

        private class UserActivityPreferences
        {
            public List<int> PreferredActivityTypeIds { get; set; } = new();
            public float PreferredAvgFee { get; set; }
            public float PreferredAvgDuration { get; set; }
            public float PreferredLocationLat { get; set; }
            public float PreferredLocationLon { get; set; }
        }
    }
} 