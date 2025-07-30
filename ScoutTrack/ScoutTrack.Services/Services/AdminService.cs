using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class AdminService : BaseCRUDService<AdminResponse, AdminSearchObject, Admin, AdminInsertRequest, AdminUpdateRequest>, IAdminService
    {
        private readonly ScoutTrackDbContext _context;

        public AdminService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper) 
        {
            _context = context;
        }

        protected override IQueryable<Admin> ApplyFilter(IQueryable<Admin> query, AdminSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(a => a.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(a => a.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.FullName))
            {
                query = query.Where(a => a.FullName.Contains(search.FullName));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => a.Username.Contains(search.FTS) || 
                                        a.Email.Contains(search.FTS) || 
                                        a.FullName.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(Admin entity, AdminInsertRequest request)
        {
            entity.Role = Role.Admin;
            
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email))
                throw new UserException("User with this email already exists.");

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Password and confirmation do not match.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        protected override async Task BeforeUpdate(Admin entity, AdminUpdateRequest request)
        {
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username && ua.Id != entity.Id))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email && ua.Id != entity.Id))
                throw new UserException("User with this email already exists.");
        }

        protected override void MapUpdateToEntity(Admin entity, AdminUpdateRequest request)
        {
            entity.UpdatedAt = DateTime.UtcNow;
            base.MapUpdateToEntity(entity, request);
        }

        public async Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request)
        {
            var entity = await _context.Admins.FindAsync(id);
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
    }
} 