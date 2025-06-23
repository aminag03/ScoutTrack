using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class UserService : IUserService
    {
        private readonly ScoutTrackDbContext _context;

        public UserService(ScoutTrackDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<UserResponse>> GetAsync(UserSearchObject search)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(search.Username))
                query = query.Where(u => u.Username.Contains(search.Username));
            if (!string.IsNullOrEmpty(search.Email))
                query = query.Where(u => u.Email.Contains(search.Email));

            return await query.Select(u => new UserResponse
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                PhoneNumber = u.PhoneNumber,
                IsActive = u.IsActive
            }).ToListAsync();
        }

        public async Task<UserResponse?> GetByIdAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return null;

            return new UserResponse
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive
            };
        }

        public async Task<UserResponse> CreateAsync(UserUpsertRequest user)
        {
            if (await _context.Users.AnyAsync(u => u.Email == user.Email))
                throw new Exception("Email already exists.");

            if (await _context.Users.AnyAsync(u => u.Username == user.Username))
                throw new Exception("Username already exists.");


            var entity = new User
            {
                Username = user.Username,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                PasswordHash = user.Password != null ? HashPassword(user.Password) : null
            };

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            return new UserResponse
            {
                Id = entity.Id,
                Username = entity.Username,
                Email = entity.Email,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                PhoneNumber = entity.PhoneNumber,
                IsActive = entity.IsActive
            };
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest user)
        {
            var entity = await _context.Users.FindAsync(id);
            if (entity == null) return null;

            if (await _context.Users.AnyAsync(u => u.Email == user.Email))
                throw new Exception("Email already exists.");

            if (await _context.Users.AnyAsync(u => u.Username == user.Username))
                throw new Exception("Username already exists.");


            entity.Username = user.Username;
            entity.Email = user.Email;
            entity.FirstName = user.FirstName;
            entity.LastName = user.LastName;
            entity.PhoneNumber = user.PhoneNumber;
            entity.IsActive = user.IsActive;

            if (!string.IsNullOrEmpty(user.Password))
                entity.PasswordHash = HashPassword(user.Password);

            await _context.SaveChangesAsync();

            return new UserResponse
            {
                Id = entity.Id,
                Username = entity.Username,
                Email = entity.Email,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                PhoneNumber = entity.PhoneNumber,
                IsActive = entity.IsActive
            };
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Users.FindAsync(id);
            if (entity == null) return false;

            _context.Users.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        private string HashPassword(string password)
        {
            // TODO: Implement a proper password hashing mechanism
            return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(password));
        }
    }
}
