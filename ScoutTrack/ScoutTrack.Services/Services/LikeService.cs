using System.Security.Claims;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class LikeService : BaseService<LikeResponse, LikeSearchObject, Like>, ILikeService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<LikeService> _logger;
        private readonly IAccessControlService _accessControlService;

        public LikeService(ScoutTrackDbContext context, IMapper mapper, ILogger<LikeService> logger, IAccessControlService accessControlService)
            : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _accessControlService = accessControlService;
        }

        public async Task<PagedResult<LikeResponse>> GetByPostAsync(int postId, LikeSearchObject search)
        {
            search.PostId = postId;
            return await GetAsync(search);
        }

        public async Task<LikeResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            var like = await GetByIdAsync(id);
            if (like == null) return null;

            var userId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst("Role")?.Value ?? user.FindFirst(ClaimTypes.Role)?.Value ?? "";

            like.CanUnlike = await _accessControlService.CanUnlikePostAsync(user, like.PostId);

            return like;
        }

        public async Task<LikeResponse> LikePostAsync(int postId, int userId)
        {
            var existingLike = await _context.Likes
                .FirstOrDefaultAsync(l => l.PostId == postId && l.CreatedById == userId);

            if (existingLike != null)
            {
                return await GetByIdAsync(existingLike.Id);
            }

            var like = new Like
            {
                PostId = postId,
                CreatedById = userId,
                LikedAt = DateTime.UtcNow
            };

            _context.Likes.Add(like);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(like.Id);
        }

        public async Task<bool> UnlikePostAsync(int postId, int userId)
        {
            var existingLike = await _context.Likes
                .FirstOrDefaultAsync(l => l.PostId == postId && l.CreatedById == userId);

            if (existingLike != null)
            {
                _context.Likes.Remove(existingLike);
                await _context.SaveChangesAsync();
                return true;
            }

            return false;
        }

        protected override IQueryable<Like> ApplyFilter(IQueryable<Like> query, LikeSearchObject search)
        {
            if (search.PostId.HasValue)
                query = query.Where(l => l.PostId == search.PostId.Value);

            if (search.CreatedById.HasValue)
                query = query.Where(l => l.CreatedById == search.CreatedById.Value);

            return query;
        }

        protected override LikeResponse MapToResponse(Like entity)
        {
            return new LikeResponse
            {
                Id = entity.Id,
                LikedAt = entity.LikedAt,
                PostId = entity.PostId,
                CreatedById = entity.CreatedById,
                                    CreatedByName = GetUserAccountName(entity.CreatedBy),
                    CreatedByTroopName = GetUserTroopName(entity.CreatedBy),
                    CreatedByAvatarUrl = GetUserAvatarUrl(entity.CreatedBy)
            };
        }

        private string GetUserAccountName(UserAccount userAccount)
        {
            if (userAccount == null) return "Unknown User";
            
            if (userAccount is Member member)
                return $"{member.FirstName} {member.LastName}";
            else if (userAccount is Troop troop)
                return troop.Name;
            else if (userAccount is Admin admin)
                return admin.Username;
            else
                return userAccount.Username;
        }

        private string? GetUserTroopName(UserAccount userAccount)
        {
            if (userAccount == null) return null;
            
            if (userAccount is Member member)
            {
                // Get the troop name for the member
                var troop = _context.Troops.FirstOrDefault(t => t.Id == member.TroopId);
                return troop?.Name;
            }
            else if (userAccount is Troop troop)
                return null; // Troop doesn't have a troop name
            else if (userAccount is Admin admin)
                return null; // Admin doesn't have a troop
            else
                return null;
        }

        private string? GetUserAvatarUrl(UserAccount userAccount)
        {
            if (userAccount == null) return null;
            
            if (userAccount is Member member)
                return member.ProfilePictureUrl;
            else if (userAccount is Troop troop)
                return troop.LogoUrl;
            else if (userAccount is Admin admin)
                return null; // Admin doesn't have avatar
            else
                return null;
        }
    }
}
