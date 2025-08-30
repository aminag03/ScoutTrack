using System.Security.Claims;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Requests;
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
    public class CommentService : BaseCRUDService<CommentResponse, CommentSearchObject, Comment, CommentUpsertRequest, CommentUpsertRequest>, ICommentService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<CommentService> _logger;
        private readonly IAccessControlService _accessControlService;

        public CommentService(ScoutTrackDbContext context, IMapper mapper, ILogger<CommentService> logger, IAccessControlService accessControlService)
            : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _accessControlService = accessControlService;
        }

        public async Task<PagedResult<CommentResponse>> GetByPostAsync(int postId, CommentSearchObject search)
        {
            search.PostId = postId;
            return await GetAsync(search);
        }

        public async Task<CommentResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            var comment = await GetByIdAsync(id);
            if (comment == null) return null;

            var userId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst("Role")?.Value ?? user.FindFirst(ClaimTypes.Role)?.Value ?? "";

            comment.CanEdit = await _accessControlService.CanEditCommentAsync(user, id);
            comment.CanDelete = await _accessControlService.CanDeleteCommentAsync(user, id);

            return comment;
        }

        public async Task<CommentResponse> CreateForUserAsync(CommentUpsertRequest request, ClaimsPrincipal user)
        {
            var userId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            var comment = new Comment
            {
                Content = request.Content,
                PostId = request.PostId,
                CreatedById = userId,
                CreatedAt = DateTime.Now
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(comment.Id);
        }

        public override async Task<CommentResponse?> UpdateAsync(int id, CommentUpsertRequest request)
        {
            var comment = await _context.Comments.FindAsync(id);
            if (comment == null) return null;

            comment.Content = request.Content;
            comment.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        protected override IQueryable<Comment> ApplyFilter(IQueryable<Comment> query, CommentSearchObject search)
        {
            if (search.PostId.HasValue)
                query = query.Where(c => c.PostId == search.PostId.Value);

            if (search.CreatedById.HasValue)
                query = query.Where(c => c.CreatedById == search.CreatedById.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(c => c.Content.Contains(search.FTS));

            return query;
        }

        protected override CommentResponse MapToResponse(Comment entity)
        {
            return new CommentResponse
            {
                Id = entity.Id,
                Content = entity.Content,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
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
                var troop = _context.Troops.FirstOrDefault(t => t.Id == member.TroopId);
                return troop?.Name;
            }
            else if (userAccount is Troop troop)
                return null;
            else if (userAccount is Admin admin)
                return null;
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
                return null;
            else
                return null;
        }
    }
}
