using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class CityService : ICityService
    {
        private readonly ScoutTrackDbContext _context;

        public CityService(ScoutTrackDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<CityResponse>> GetAsync(CitySearchObject search)
        {
            var query = _context.Cities.AsQueryable();

            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(c => c.Name.Contains(search.Name));

            return await query
                .Select(c => new CityResponse
                {
                    Id = c.Id,
                    Name = c.Name,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();
        }

        public async Task<CityResponse?> GetByIdAsync(int id)
        {
            var city = await _context.Cities.FindAsync(id);
            if (city == null) return null;

            return new CityResponse
            {
                Id = city.Id,
                Name = city.Name,
                CreatedAt = city.CreatedAt,
                UpdatedAt = city.UpdatedAt
            };
        }

        public async Task<CityResponse> CreateAsync(CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name))
                throw new InvalidOperationException("City with this name already exists.");

            var entity = new City
            {
                Name = request.Name,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.Cities.Add(entity);
            await _context.SaveChangesAsync();

            return new CityResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<CityResponse?> UpdateAsync(int id, CityUpsertRequest request)
        {
            var entity = await _context.Cities.FindAsync(id);
            if (entity == null) return null;

            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.Id != id))
                throw new InvalidOperationException("Another city with this name already exists.");

            entity.Name = request.Name;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new CityResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Cities.FindAsync(id);
            if (entity == null) return false;

            _context.Cities.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
} 