using System.Security.Claims;
using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class PostService : BaseCRUDService<PostResponse, PostSearchObject, Post, PostUpsertRequest, PostUpsertRequest>, IPostService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<PostService> _logger;
        private readonly IWebHostEnvironment _env;
        private readonly IAccessControlService _accessControlService;

        public PostService(ScoutTrackDbContext context, IMapper mapper, ILogger<PostService> logger, IWebHostEnvironment env, IAccessControlService accessControlService) 
            : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _env = env;
            _accessControlService = accessControlService;
        }

        public async Task<PostResponse> CreateAsync(PostUpsertRequest request, ClaimsPrincipal user)
        {
            var userId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            
            var post = new Post
            {
                Content = request.Content,
                ActivityId = request.ActivityId,
                CreatedById = userId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();

            if (request.ImageUrls.Any())
            {
                var postImages = request.ImageUrls.Select((url, index) => new PostImage
                {
                    PostId = post.Id,
                    ImageUrl = url,
                    UploadedAt = DateTime.UtcNow,
                    IsCoverPhoto = index == 0
                }).ToList();

                _context.PostImages.AddRange(postImages);
                await _context.SaveChangesAsync();
            }

            return await GetByIdAsync(post.Id);
        }

        public override async Task<PostResponse> CreateAsync(PostUpsertRequest request)
        {
            throw new NotImplementedException("Use CreateAsync(PostUpsertRequest request, ClaimsPrincipal user) instead");
        }

        public override async Task<PostResponse?> GetByIdAsync(int id)
        {
            var post = await _context.Posts
                .Include(p => p.Activity)
                .Include(p => p.CreatedBy)
                .Include(p => p.Images)
                .Include(p => p.Likes)
                    .ThenInclude(l => l.CreatedBy)
                .Include(p => p.Comments)
                    .ThenInclude(c => c.CreatedBy)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (post == null) return null;

            return MapToResponse(post);
        }

        public async Task<PostResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            var post = await GetByIdAsync(id);
            if (post == null) return null;

            var activity = await _context.Activities
                .Include(a => a.Troop)
                .FirstOrDefaultAsync(a => a.Id == post.ActivityId);

            if (activity == null) return null;

            if (activity.ActivityState != "FinishedActivityState")
            {
                var userId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                var userRole = user.FindFirst("Role")?.Value ?? user.FindFirst(ClaimTypes.Role)?.Value ?? "";

                if (userRole != "Admin" && (userRole != "Troop" || activity.TroopId != userId))
                {
                    return null;
                }
            }

            var currentUserId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            post.IsLikedByCurrentUser = await _context.Likes
                .AnyAsync(l => l.PostId == id && l.CreatedById == currentUserId);

            return post;
        }

        public override async Task<PagedResult<PostResponse>> GetAsync(PostSearchObject search)
        {
            var query = _context.Posts
                .Include(p => p.Activity)
                .Include(p => p.CreatedBy)
                .Include(p => p.Images)
                .Include(p => p.Likes)
                    .ThenInclude(l => l.CreatedBy)
                .Include(p => p.Comments)
                    .ThenInclude(c => c.CreatedBy)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!string.IsNullOrEmpty(search.OrderBy))
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
            else
            {
                query = query.OrderByDescending(p => p.CreatedAt);
            }

            if (!search.RetrieveAll)
            {
                var page = search.Page ?? 0;
                var pageSize = search.PageSize ?? 10;
                query = query.Skip(page * pageSize).Take(pageSize);
            }

            var posts = await query.ToListAsync();
            var responses = posts.Select(MapToResponse).ToList();

            // Set IsLikedByCurrentUser flag for each post
            // Note: This would require the current user context, which is not available in this method
            // The flag will be set when calling GetByIdForUserAsync or when posts are loaded with user context

            return new PagedResult<PostResponse>
            {
                Items = responses,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Post> ApplyFilter(IQueryable<Post> query, PostSearchObject search)
        {
            if (search.ActivityId.HasValue)
                query = query.Where(p => p.ActivityId == search.ActivityId.Value);

            if (search.CreatedById.HasValue)
                query = query.Where(p => p.CreatedById == search.CreatedById.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(p => p.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(p => p.CreatedAt <= search.CreatedTo.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(p => p.Content.Contains(search.FTS));

            return query;
        }

        public async Task<PagedResult<PostResponse>> GetByActivityAsync(int activityId, PostSearchObject search)
        {
            search.ActivityId = activityId;
            return await GetAsync(search);
        }

        public async Task<PagedResult<PostResponse>> GetByActivityForUserAsync(int activityId, PostSearchObject search, ClaimsPrincipal user)
        {
            search.ActivityId = activityId;
            var result = await GetAsync(search);
            
            var currentUserId = int.Parse(user.FindFirst("UserId")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            
            foreach (var post in result.Items)
            {
                post.IsLikedByCurrentUser = await _context.Likes
                    .AnyAsync(l => l.PostId == post.Id && l.CreatedById == currentUserId);
                
                foreach (var comment in post.Comments)
                {
                    comment.CanEdit = await _accessControlService.CanEditCommentAsync(user, comment.Id);
                    comment.CanDelete = await _accessControlService.CanDeleteCommentAsync(user, comment.Id);
                }
                
                foreach (var like in post.Likes)
                {
                    like.CanUnlike = await _accessControlService.CanUnlikePostAsync(user, like.PostId);
                }
            }
            
            return result;
        }

        public override async Task<PostResponse?> UpdateAsync(int id, PostUpsertRequest request)
        {
            var post = await _context.Posts
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (post == null)
                return null;

            var oldImageUrls = post.Images.Select(img => img.ImageUrl).ToList();

            post.Content = request.Content;
            post.UpdatedAt = DateTime.UtcNow;

            _context.PostImages.RemoveRange(post.Images);

            if (request.ImageUrls.Any())
            {
                var postImages = request.ImageUrls.Select((url, index) => new PostImage
                {
                    PostId = post.Id,
                    ImageUrl = url,
                    UploadedAt = DateTime.UtcNow,
                    IsCoverPhoto = index == 0
                }).ToList();

                _context.PostImages.AddRange(postImages);
            }

            await _context.SaveChangesAsync();

            var imagesToDelete = oldImageUrls.Where(oldUrl => !request.ImageUrls.Contains(oldUrl)).ToList();
            foreach (var imageUrl in imagesToDelete)
            {
                DeleteImageFile(imageUrl);
            }

            return await GetByIdAsync(id);
        }

        protected override async Task BeforeDelete(Post entity)
        {
            await _context.Entry(entity)
                .Collection(p => p.Images)
                .LoadAsync();

            foreach (var image in entity.Images)
            {
                DeleteImageFile(image.ImageUrl);
            }
        }

        public async Task<PostResponse> LikePostAsync(int postId, int userId)
        {
            var existingLike = await _context.Likes
                .FirstOrDefaultAsync(l => l.PostId == postId && l.CreatedById == userId);

            if (existingLike == null)
            {
                var like = new Like
                {
                    PostId = postId,
                    CreatedById = userId,
                    LikedAt = DateTime.UtcNow
                };

                _context.Likes.Add(like);
                await _context.SaveChangesAsync();
            }

            return await GetByIdAsync(postId);
        }

        public async Task<PostResponse> UnlikePostAsync(int postId, int userId)
        {
            var existingLike = await _context.Likes
                .FirstOrDefaultAsync(l => l.PostId == postId && l.CreatedById == userId);

            if (existingLike != null)
            {
                _context.Likes.Remove(existingLike);
                await _context.SaveChangesAsync();
            }

            return await GetByIdAsync(postId);
        }

        protected override PostResponse MapToResponse(Post entity)
        {
            return new PostResponse
            {
                Id = entity.Id,
                Content = entity.Content,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ActivityId = entity.ActivityId,
                ActivityTitle = entity.Activity?.Title ?? "",
                CreatedById = entity.CreatedById,
                CreatedByName = GetUserName(entity.CreatedBy),
                CreatedByTroopName = GetUserTroopName(entity.CreatedBy),
                CreatedByAvatarUrl = GetUserAvatarUrl(entity.CreatedBy),
                Images = entity.Images.Select(i => new PostImageResponse
                {
                    Id = i.Id,
                    ImageUrl = i.ImageUrl,
                    UploadedAt = i.UploadedAt,
                    IsCoverPhoto = i.IsCoverPhoto
                }).ToList(),
                LikeCount = entity.Likes.Count,
                CommentCount = entity.Comments.Count,
                IsLikedByCurrentUser = false,
                Likes = entity.Likes.Select(l => new LikeResponse
                {
                    Id = l.Id,
                    LikedAt = l.LikedAt,
                    PostId = l.PostId,
                    CreatedById = l.CreatedById,
                    CreatedByName = GetUserAccountName(l.CreatedBy),
                    CreatedByTroopName = GetUserTroopName(l.CreatedBy),
                    CreatedByAvatarUrl = GetUserAvatarUrl(l.CreatedBy)
                }).ToList(),
                Comments = entity.Comments.Select(c => new CommentResponse
                {
                    Id = c.Id,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    PostId = c.PostId,
                    CreatedById = c.CreatedById,
                    CreatedByName = GetUserAccountName(c.CreatedBy),
                    CreatedByTroopName = GetUserTroopName(c.CreatedBy),
                    CreatedByAvatarUrl = GetUserAvatarUrl(c.CreatedBy)
                }).ToList()
            };
        }

        private string GetUserName(UserAccount user)
        {
            if (user is Member member)
                return $"{member.FirstName} {member.LastName}";
            if (user is Troop troop)
                return troop.Name;
            if (user is Admin admin)
                return admin.FullName;
            return "Unknown User";
        }

        private string GetUserRole(UserAccount user)
        {
            return user.Role.ToString();
        }

        private string GetUserAccountName(UserAccount userAccount)
        {
            if (userAccount == null) return "Unknown User";
            
            if (userAccount is Member member)
                return $"{member.FirstName} {member.LastName}";
            else if (userAccount is Troop troop)
                return troop.Name;
            else if (userAccount is Admin admin)
                return admin.FullName;
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

        private void DeleteImageFile(string imageUrl)
        {
            if (string.IsNullOrWhiteSpace(imageUrl))
                return;

            try
            {
                var uri = new Uri(imageUrl);
                var relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                    _logger.LogInformation($"Deleted post image file: {fullPath}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error while deleting post image file: {imageUrl}", imageUrl);
            }
        }
    }
}