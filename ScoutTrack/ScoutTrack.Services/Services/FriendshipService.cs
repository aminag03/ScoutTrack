using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
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
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class FriendshipService : BaseCRUDService<FriendshipResponse, FriendshipSearchObject, Friendship, FriendshipUpsertRequest, FriendshipUpsertRequest>, IFriendshipService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<FriendshipService> _logger;

        public FriendshipService(ScoutTrackDbContext context, IMapper mapper, ILogger<FriendshipService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        public override async Task<PagedResult<FriendshipResponse>> GetAsync(FriendshipSearchObject search)
        {
            var query = _context.Set<Friendship>()
                .Include(f => f.Requester)
                .Include(f => f.Responder)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;
                bool descending = orderBy.StartsWith("-");
                if (descending) orderBy = orderBy[1..];

                query = orderBy.ToLower() switch
                {
                    "requestedat" => descending
                        ? query.OrderByDescending(f => f.RequestedAt)
                        : query.OrderBy(f => f.RequestedAt),
                    "respondedat" => descending
                        ? query.OrderByDescending(f => f.RespondedAt)
                        : query.OrderBy(f => f.RespondedAt),
                    "status" => descending
                        ? query.OrderByDescending(f => f.Status)
                        : query.OrderBy(f => f.Status),
                    _ => query
                };
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query
                    .Skip(search.Page.Value * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var entities = await query.ToListAsync();
            var responseList = entities.Select(MapToResponse).ToList();

            return new PagedResult<FriendshipResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Friendship> ApplyFilter(IQueryable<Friendship> query, FriendshipSearchObject search)
        {
            if (search.RequesterId.HasValue)
            {
                query = query.Where(f => f.RequesterId == search.RequesterId.Value);
            }

            if (search.ResponderId.HasValue)
            {
                query = query.Where(f => f.ResponderId == search.ResponderId.Value);
            }

            if (search.Status.HasValue)
            {
                query = query.Where(f => f.Status == search.Status.Value);
            }

            if (search.MemberId.HasValue)
            {
                query = query.Where(f => f.RequesterId == search.MemberId.Value || f.ResponderId == search.MemberId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(f => f.Requester.Username.Contains(search.FTS) ||
                                        f.Requester.FirstName.Contains(search.FTS) ||
                                        f.Requester.LastName.Contains(search.FTS) ||
                                        f.Responder.Username.Contains(search.FTS) ||
                                        f.Responder.FirstName.Contains(search.FTS) ||
                                        f.Responder.LastName.Contains(search.FTS));
            }

            return query;
        }

        public override async Task<FriendshipResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Friendships
                .Include(f => f.Requester)
                .Include(f => f.Responder)
                .FirstOrDefaultAsync(f => f.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Friendship entity, FriendshipUpsertRequest request)
        {
            if (!await _context.Members.AnyAsync(m => m.Id == request.RequesterId))
                throw new UserException($"Requester with ID {request.RequesterId} does not exist.");

            if (!await _context.Members.AnyAsync(m => m.Id == request.ResponderId))
                throw new UserException($"Responder with ID {request.ResponderId} does not exist.");

            if (request.RequesterId == request.ResponderId)
                throw new UserException("Cannot send friend request to yourself.");

            var existingFriendship = await _context.Friendships
                .FirstOrDefaultAsync(f => (f.RequesterId == request.RequesterId && f.ResponderId == request.ResponderId) ||
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

            if (request.Status == FriendshipStatus.Accepted)
            {
                entity.RespondedAt = DateTime.Now;
            }
        }

        public async Task<FriendshipResponse?> SendFriendRequestAsync(int requesterId, int responderId)
        {
            var request = new FriendshipUpsertRequest
            {
                RequesterId = requesterId,
                ResponderId = responderId,
                Status = FriendshipStatus.Pending
            };

            return await CreateAsync(request);
        }

        public async Task<FriendshipResponse?> AcceptFriendRequestAsync(int friendshipId, int responderId)
        {
            var friendship = await _context.Friendships
                .Include(f => f.Requester)
                .Include(f => f.Responder)
                .FirstOrDefaultAsync(f => f.Id == friendshipId && f.ResponderId == responderId);

            if (friendship == null)
                return null;

            if (friendship.Status != FriendshipStatus.Pending)
                throw new UserException("This friend request is not pending.");

            friendship.Status = FriendshipStatus.Accepted;
            friendship.RespondedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToResponse(friendship);
        }

        public async Task<bool> RejectFriendRequestAsync(int friendshipId, int responderId)
        {
            var friendship = await _context.Friendships
                .FirstOrDefaultAsync(f => f.Id == friendshipId && f.ResponderId == responderId);

            if (friendship == null)
                return false;

            if (friendship.Status != FriendshipStatus.Pending)
                throw new UserException("This friend request is not pending.");

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UnfriendAsync(int friendshipId, int memberId)
        {
            var friendship = await _context.Friendships
                .FirstOrDefaultAsync(f => f.Id == friendshipId && 
                                        (f.RequesterId == memberId || f.ResponderId == memberId) &&
                                        f.Status == FriendshipStatus.Accepted);

            if (friendship == null)
                return false;

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CancelFriendRequestAsync(int friendshipId, int requesterId)
        {
            var friendship = await _context.Friendships
                .FirstOrDefaultAsync(f => f.Id == friendshipId && 
                                        f.RequesterId == requesterId &&
                                        f.Status == FriendshipStatus.Pending);

            if (friendship == null)
                return false;

            _context.Friendships.Remove(friendship);
            await _context.SaveChangesAsync();
            return true;
        }

        protected override FriendshipResponse MapToResponse(Friendship entity)
        {
            return new FriendshipResponse
            {
                Id = entity.Id,
                RequesterId = entity.RequesterId,
                RequesterUsername = entity.Requester?.Username ?? string.Empty,
                RequesterFirstName = entity.Requester?.FirstName ?? string.Empty,
                RequesterLastName = entity.Requester?.LastName ?? string.Empty,
                RequesterProfilePictureUrl = entity.Requester?.ProfilePictureUrl ?? string.Empty,
                ResponderId = entity.ResponderId,
                ResponderUsername = entity.Responder?.Username ?? string.Empty,
                ResponderFirstName = entity.Responder?.FirstName ?? string.Empty,
                ResponderLastName = entity.Responder?.LastName ?? string.Empty,
                ResponderProfilePictureUrl = entity.Responder?.ProfilePictureUrl ?? string.Empty,
                RequestedAt = entity.RequestedAt,
                RespondedAt = entity.RespondedAt,
                Status = entity.Status,
                StatusName = entity.Status.ToString()
            };
        }
    }
}
