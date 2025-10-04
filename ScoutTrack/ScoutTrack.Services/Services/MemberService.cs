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
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class MemberService : BaseCRUDService<MemberResponse, MemberSearchObject, Member, MemberInsertRequest, MemberUpdateRequest>, IMemberService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<MemberService> _logger;
        private readonly IWebHostEnvironment _env;

        public MemberService(ScoutTrackDbContext context, IMapper mapper, ILogger<MemberService> logger, IWebHostEnvironment env) : base(context, mapper) 
        {
            _context = context;
            _logger = logger;
            _env = env;
        }

        public override async Task<PagedResult<MemberResponse>> GetAsync(MemberSearchObject search)
        {
            var query = _context.Set<Member>()
                .Include(m => m.City)
                .Include(m => m.Troop)
                .Include(m => m.Category)
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
                    "firstname" => descending
                        ? query.OrderByDescending(m => m.FirstName)
                        : query.OrderBy(m => m.FirstName),
                    "lastname" => descending
                        ? query.OrderByDescending(m => m.LastName)
                        : query.OrderBy(m => m.LastName),
                    "email" => descending
                        ? query.OrderByDescending(m => m.Email)
                        : query.OrderBy(m => m.Email),
                    "username" => descending
                        ? query.OrderByDescending(m => m.Username)
                        : query.OrderBy(m => m.Username),
                    "birthdate" => descending
                        ? query.OrderByDescending(m => m.BirthDate)
                        : query.OrderBy(m => m.BirthDate),
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
            var responseList = _mapper.Map<List<MemberResponse>>(entities);

            return new PagedResult<MemberResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Member> ApplyFilter(IQueryable<Member> query, MemberSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(m => m.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(m => m.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.FirstName))
            {
                query = query.Where(m => m.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrEmpty(search.LastName))
            {
                query = query.Where(m => m.LastName.Contains(search.LastName));
            }

            if (search.TroopId.HasValue)
            {
                query = query.Where(m => m.TroopId == search.TroopId.Value);
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(m => m.CityId == search.CityId.Value);
            }

            if (search.Gender.HasValue)
            {
                query = query.Where(m => m.Gender == search.Gender.Value);
            }

            if (search.CategoryId.HasValue)
            {
                query = query.Where(m => m.CategoryId == search.CategoryId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(m => m.Username.Contains(search.FTS) ||
                                        m.FirstName.Contains(search.FTS) ||
                                        m.LastName.Contains(search.FTS));
            }
            return query;
        }

        public override async Task<MemberResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Members
                .Include(t => t.City)
                .Include(m => m.Troop)
                .Include(m => m.Category)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Member entity, MemberInsertRequest request)
        {
            entity.Role = Role.Member;
            
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email))
                throw new UserException("User with this email already exists.");

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Password and confirmation do not match.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            entity.Gender = request.Gender;

            var today = DateTime.Today;
            var age = today.Year - request.BirthDate.Year;
            if (request.BirthDate.Date > today.AddYears(-age)) age--;
            var category = await _context.Categories.FirstOrDefaultAsync(c => c.MinAge <= age && c.MaxAge >= age);
            entity.CategoryId = category?.Id;
        }

        protected override async Task BeforeUpdate(Member entity, MemberUpdateRequest request)
        {
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username && ua.Id != entity.Id))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email && ua.Id != entity.Id))
                throw new UserException("User with this email already exists.");

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");

            entity.Gender = request.Gender;
        }

        protected override async Task BeforeDelete(Member entity)
        {
            if (!string.IsNullOrWhiteSpace(entity.ProfilePictureUrl))
            {
                try
                {
                    string relativePath;
                    if (entity.ProfilePictureUrl.StartsWith("http"))
                    {
                        var uri = new Uri(entity.ProfilePictureUrl);
                        relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ProfilePictureUrl.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting member profile picture from file system.");
                }
            }

            var activityRegistrations = await _context.ActivityRegistrations
                .Where(ar => ar.MemberId == entity.Id)
                .ToListAsync();
            _context.ActivityRegistrations.RemoveRange(activityRegistrations);

            var friendships = await _context.Friendships
                .Where(f => f.RequesterId == entity.Id || f.ResponderId == entity.Id)
                .ToListAsync();
            _context.Friendships.RemoveRange(friendships);

            var memberBadgeProgress = await _context.MemberBadgeProgresses
                .Where(mbp => _context.MemberBadges.Any(mb => mb.Id == mbp.MemberBadgeId && mb.MemberId == entity.Id))
                .ToListAsync();
            _context.MemberBadgeProgresses.RemoveRange(memberBadgeProgress);

            var memberBadges = await _context.MemberBadges
                .Where(mb => mb.MemberId == entity.Id)
                .ToListAsync();
            _context.MemberBadges.RemoveRange(memberBadges);

            var reviews = await _context.Reviews
                .Where(r => r.MemberId == entity.Id)
                .ToListAsync();
            _context.Reviews.RemoveRange(reviews);

            var notifications = await _context.Notifications
                .Where(n => n.ReceiverId == entity.Id)
                .ToListAsync();
            _context.Notifications.RemoveRange(notifications);

            var memberPosts = await _context.Posts
                .Where(p => p.CreatedById == entity.Id)
                .ToListAsync();

            if (memberPosts.Any())
            {
                var postIds = memberPosts.Select(p => p.Id).ToList();

                var comments = await _context.Comments
                    .Where(c => postIds.Contains(c.PostId))
                    .ToListAsync();
                _context.Comments.RemoveRange(comments);

                var likes = await _context.Likes
                    .Where(l => postIds.Contains(l.PostId))
                    .ToListAsync();
                _context.Likes.RemoveRange(likes);

                var postImages = await _context.PostImages
                    .Where(pi => postIds.Contains(pi.PostId))
                    .ToListAsync();
                _context.PostImages.RemoveRange(postImages);

                _context.Posts.RemoveRange(memberPosts);
            }

            var memberLikes = await _context.Likes
                .Where(l => l.CreatedById == entity.Id)
                .ToListAsync();
            _context.Likes.RemoveRange(memberLikes);

            var memberComments = await _context.Comments
                .Where(c => c.CreatedById == entity.Id)
                .ToListAsync();
            _context.Comments.RemoveRange(memberComments);

            var sentNotifications = await _context.Notifications
                .Where(n => n.SenderId == entity.Id)
                .ToListAsync();
            _context.Notifications.RemoveRange(sentNotifications);

            await _context.SaveChangesAsync();
        }

        public async Task<MemberResponse?> DeActivateAsync(int id)
        {
            var member = await _context.Set<Member>().FindAsync(id);
            if (member == null)
                return null;

            if (!member.IsActive)
                member.IsActive = true;
            else
                member.IsActive = false;

            await _context.SaveChangesAsync();
            return MapToResponse(member);
        }

        public async Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request)
        {
            var entity = await _context.Members.FindAsync(id);
            if (entity == null)
                return null;

            if (!BCrypt.Net.BCrypt.Verify(request.OldPassword, entity.PasswordHash))
                throw new UserException("Old password is not valid.");

            if (BCrypt.Net.BCrypt.Verify(request.NewPassword, entity.PasswordHash))
                throw new UserException("New password cannot be same as old password.");

            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
                throw new UserException("New password must have at least 8 characters.");

            if (request.NewPassword != request.ConfirmNewPassword)
                throw new UserException("New password and confirmation do not match.");

            if (!Regex.IsMatch(request.NewPassword, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"))
                throw new UserException("Password must contain at least one uppercase letter, one " +
                    "lowercase letter, one number and one special character.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool?> AdminChangePasswordAsync(int id, AdminChangePasswordRequest request)
        {
            var entity = await _context.Members.FindAsync(id);
            if (entity == null)
                return null;

            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
                throw new UserException("New password must have at least 8 characters.");

            if (request.NewPassword != request.ConfirmNewPassword)
                throw new UserException("New password and confirmation do not match.");

            if (!Regex.IsMatch(request.NewPassword, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"))
                throw new UserException("Password must contain at least one uppercase letter, one " +
                    "lowercase letter, one number and one special character.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<MemberResponse?> UpdateProfilePictureAsync(int id, string? profilePictureUrl)
        {
            var entity = await _context.Members.FindAsync(id);
            if (entity == null)
                return null;

            if (!string.IsNullOrWhiteSpace(entity.ProfilePictureUrl))
            {
                try
                {
                    string relativePath;
                    if (entity.ProfilePictureUrl.StartsWith("http"))
                    {
                        var oldUri = new Uri(entity.ProfilePictureUrl);
                        relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ProfilePictureUrl.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting old profile picture");
                }
            }

            entity.ProfilePictureUrl = string.IsNullOrWhiteSpace(profilePictureUrl) ? "" : profilePictureUrl;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<MemberResponse>(entity);
        }

        public async Task UpdateAllMemberCategoriesAsync()
        {
            var today = DateTime.Today;
            var categories = await _context.Categories.ToListAsync();
            var members = await _context.Members.ToListAsync();

            foreach (var member in members)
            {
                var age = today.Year - member.BirthDate.Year;
                if (member.BirthDate.Date > today.AddYears(-age)) age--;
                var category = categories.FirstOrDefault(c => c.MinAge <= age && c.MaxAge >= age);
                member.CategoryId = category?.Id;
            }
            await _context.SaveChangesAsync();
        }

        protected override MemberResponse MapToResponse(Member entity)
        {
            return new MemberResponse
            {
                Id = entity.Id,
                Username = entity.Username,
                Email = entity.Email,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                BirthDate = entity.BirthDate,
                Gender = entity.Gender,
                GenderName = entity.Gender == 0 ? Gender.Male.ToString() : Gender.Female.ToString(),
                CategoryId = entity.CategoryId,
                CategoryName = entity.Category?.Name ?? string.Empty,
                ContactPhone = entity.ContactPhone,
                ProfilePictureUrl = entity.ProfilePictureUrl ?? string.Empty,
                TroopId = entity.TroopId,
                TroopName = entity.Troop?.Name ?? string.Empty,
                CityId = entity.CityId,
                CityName = entity.City?.Name ?? string.Empty,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                LastLoginAt = entity.LastLoginAt,
            };
        }
    }
}