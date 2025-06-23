using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class BadgeService : IBadgeService
    {
        private readonly ScoutTrackDbContext _context;

        public BadgeService(ScoutTrackDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<BadgeResponse>> GetAsync(BadgeSearchObject search)
        {
            var query = _context.Badges.AsQueryable();

            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(b => b.Name.Contains(search.Name));

            return await query
                .Select(b => new BadgeResponse
                {
                    Id = b.Id,
                    Name = b.Name,
                    ImageUrl = b.ImageUrl,
                    Description = b.Description,
                    CreatedAt = b.CreatedAt,
                    UpdatedAt = b.UpdatedAt
                })
                .ToListAsync();
        }

        public async Task<BadgeResponse?> GetByIdAsync(int id)
        {
            var badge = await _context.Badges.FindAsync(id);
            if (badge == null) return null;

            return new BadgeResponse
            {
                Id = badge.Id,
                Name = badge.Name,
                ImageUrl = badge.ImageUrl,
                Description = badge.Description,
                CreatedAt = badge.CreatedAt,
                UpdatedAt = badge.UpdatedAt
            };
        }

        public async Task<BadgeResponse> CreateAsync(BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name))
                throw new Exception("Badge with this name already exists.");

            var entity = new Badge
            {
                Name = request.Name,
                ImageUrl = request.ImageUrl,
                Description = request.Description,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Badges.Add(entity);
            await _context.SaveChangesAsync();

            return new BadgeResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                ImageUrl = entity.ImageUrl,
                Description = entity.Description,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<BadgeResponse?> UpdateAsync(int id, BadgeUpsertRequest request)
        {
            var entity = await _context.Badges.FindAsync(id);
            if (entity == null) return null;

            if (await _context.Badges.AnyAsync(b => b.Name == request.Name && b.Id != id))
                throw new Exception("Another badge with this name already exists.");

            entity.Name = request.Name;
            entity.ImageUrl = request.ImageUrl;
            entity.Description = request.Description;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return new BadgeResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                ImageUrl = entity.ImageUrl,
                Description = entity.Description,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Badges.FindAsync(id);
            if (entity == null) return false;

            _context.Badges.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}