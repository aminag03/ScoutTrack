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

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(m => m.Username.Contains(search.FTS) || 
                                        m.Email.Contains(search.FTS) || 
                                        m.FirstName.Contains(search.FTS) ||
                                        m.LastName.Contains(search.FTS));
            }
            return query;
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

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            entity.Gender = request.Gender;
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
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<MemberResponse?> UpdateProfilePictureAsync(int id, string profilePictureUrl)
        {
            var entity = await _context.Members.FindAsync(id);
            if (entity == null)
                return null;

            if (!string.IsNullOrWhiteSpace(entity.ProfilePictureUrl))
            {
                try
                {
                    var oldUri = new Uri(entity.ProfilePictureUrl);
                    var relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);

                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);
                    if (File.Exists(fullPath))
                    {
                        File.Delete(fullPath);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Greška pri brisanju stare slike");
                }
            }

            entity.ProfilePictureUrl = profilePictureUrl;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<MemberResponse>(entity);
        }
    }
} 