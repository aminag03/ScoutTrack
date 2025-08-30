using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using System.Security.Claims;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly IAccessControlService _accessControlService;

        public ReviewService(ScoutTrackDbContext context, IMapper mapper, IAccessControlService accessControlService) 
            : base(context, mapper)
        {
            _context = context;
            _accessControlService = accessControlService;
        }

        public override async Task<ReviewResponse> CreateAsync(ReviewUpsertRequest request)
        {
            throw new UserException("Use CreateForMemberAsync instead of CreateAsync for reviews.");
        }

        public async Task<PagedResult<ReviewResponse>> GetByActivityAsync(int activityId, ReviewSearchObject search)
        {
            search.ActivityId = activityId;
            return await GetAsync(search);
        }

        public async Task<ReviewResponse?> GetByActivityAndMemberAsync(int activityId, int memberId)
        {
            var review = await _context.Reviews
                .Include(r => r.Activity)
                .Include(r => r.Member)
                .FirstOrDefaultAsync(r => r.ActivityId == activityId && r.MemberId == memberId);

            if (review == null)
                return null;

            return MapToResponse(review);
        }

        public async Task<bool> CanMemberReviewActivityAsync(int activityId, int memberId)
        {
            var activity = await _context.Activities.FindAsync(activityId);
            if (activity == null || activity.ActivityState != "FinishedActivityState")
                return false;

            var registration = await _context.ActivityRegistrations
                .FirstOrDefaultAsync(ar => ar.ActivityId == activityId && ar.MemberId == memberId);

            return registration != null && registration.Status == Common.Enums.RegistrationStatus.Completed;
        }

        public async Task<ReviewResponse> CreateForMemberAsync(ClaimsPrincipal user, ReviewUpsertRequest request)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (userId == 0)
                throw new UnauthorizedAccessException("User ID not found in token");

            if (!await _accessControlService.CanReviewActivityAsync(user, request.ActivityId))
                throw new UserException("You cannot review this activity. Activity must be finished and you must have a completed registration.");

            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.ActivityId == request.ActivityId && r.MemberId == userId);

            if (existingReview != null)
                throw new UserException("You have already reviewed this activity");

            var review = new Review
            {
                ActivityId = request.ActivityId,
                MemberId = userId,
                Content = request.Content,
                Rating = request.Rating,
                CreatedAt = DateTime.Now
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(review.Id);
        }

        public async Task<ReviewResponse?> UpdateForMemberAsync(ClaimsPrincipal user, int id, ReviewUpsertRequest request)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (userId == 0)
                throw new UnauthorizedAccessException("User ID not found in token");

            if (!await _accessControlService.CanModifyReviewAsync(user, id))
                throw new UserException("You can only update your own reviews");

            var review = await _context.Reviews.FindAsync(id);
            if (review == null)
                return null;

            review.Content = request.Content;
            review.Rating = request.Rating;
            review.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteForMemberAsync(ClaimsPrincipal user, int id)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (userId == 0)
                throw new UnauthorizedAccessException("User ID not found in token");

            if (!await _accessControlService.CanModifyReviewAsync(user, id))
                throw new UserException("You can only delete your own reviews");

            var review = await _context.Reviews.FindAsync(id);
            if (review == null)
                return false;

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();

            return true;
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (search.ActivityId.HasValue)
                query = query.Where(r => r.ActivityId == search.ActivityId.Value);

            if (search.MemberId.HasValue)
                query = query.Where(r => r.MemberId == search.MemberId.Value);

            if (search.Rating.HasValue)
                query = query.Where(r => r.Rating == search.Rating.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(r => r.Member.FirstName.Contains(search.FTS) || r.Member.LastName.Contains(search.FTS));

            return query;
        }

        public override async Task<PagedResult<ReviewResponse>> GetAsync(ReviewSearchObject search)
        {
            var query = _context.Reviews.AsQueryable();

            query = ApplyFilter(query, search);

            var totalCount = search.IncludeTotalCount ? await query.CountAsync() : 0;

            query = ApplyOrderBy(query, search);

            if (!search.RetrieveAll)
            {
                query = query.Skip((search.Page ?? 0) * (search.PageSize ?? 10))
                            .Take(search.PageSize ?? 10);
            }

            var reviews = await query
                .Include(r => r.Activity)
                .Include(r => r.Member)
                .ToListAsync();

            var responses = reviews.Select(MapToResponse).ToList();

            return new PagedResult<ReviewResponse>
            {
                Items = responses,
                TotalCount = totalCount
            };
        }

        public override async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var review = await _context.Reviews
                .Include(r => r.Activity)
                .Include(r => r.Member)
                .FirstOrDefaultAsync(r => r.Id == id);

            return review != null ? MapToResponse(review) : null;
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            return new ReviewResponse
            {
                Id = entity.Id,
                Content = entity.Content,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                Rating = entity.Rating,
                ActivityId = entity.ActivityId,
                MemberId = entity.MemberId,
                ActivityTitle = entity.Activity?.Title ?? "",
                MemberName = entity.Member != null ? $"{entity.Member.FirstName} {entity.Member.LastName}" : ""
            };
        }

        protected override Review MapInsertToEntity(Review entity, ReviewUpsertRequest request)
        {
            entity.ActivityId = request.ActivityId;
            entity.Content = request.Content;
            entity.Rating = request.Rating;
            entity.CreatedAt = DateTime.Now;
            return entity;
        }

        protected override void MapUpdateToEntity(Review entity, ReviewUpsertRequest request)
        {
            entity.Content = request.Content;
            entity.Rating = request.Rating;
            entity.UpdatedAt = DateTime.Now;
        }

        private IQueryable<Review> ApplyOrderBy(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.OrderBy))
            {
                switch (search.OrderBy.ToLower())
                {
                    case "rating":
                        query = query.OrderBy(r => r.Rating);
                        break;
                    case "rating_desc":
                        query = query.OrderByDescending(r => r.Rating);
                        break;
                    case "createdat":
                        query = query.OrderBy(r => r.CreatedAt);
                        break;
                    case "createdat_desc":
                        query = query.OrderByDescending(r => r.CreatedAt);
                        break;
                    default:
                        query = query.OrderByDescending(r => r.CreatedAt);
                        break;
                }
            }
            else
            {
                query = query.OrderByDescending(r => r.CreatedAt);
            }

            return query;
        }
    }
}
