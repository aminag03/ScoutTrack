using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
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
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CategoryUpsertRequest, CategoryUpsertRequest>, ICategoryService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<CategoryService> _logger;

        public CategoryService(ScoutTrackDbContext context, IMapper mapper, ILogger<CategoryService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, CategorySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(c => c.Name.Contains(search.Name));
            }

            if (search.MinAge.HasValue)
            {
                query = query.Where(c => c.MinAge >= search.MinAge.Value);
            }

            if (search.MaxAge.HasValue)
            {
                query = query.Where(c => c.MaxAge <= search.MaxAge.Value);
            }

            return query;
        }

        protected override CategoryResponse MapToResponse(Category entity)
        {
            return new CategoryResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                MinAge = entity.MinAge,
                MaxAge = entity.MaxAge,
                Description = entity.Description,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
            };
        }

        protected override async Task BeforeInsert(Category entity, CategoryUpsertRequest request)
        {
            await ValidateCategoryRequestAsync(request,
                null);
        }

        protected override async Task BeforeUpdate(Category entity, CategoryUpsertRequest request)
        {
            await ValidateCategoryRequestAsync(request, entity.Id);
        }

        protected override void MapUpdateToEntity(Category entity, CategoryUpsertRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
            base.MapUpdateToEntity(entity, request);
        }

        private async Task ValidateCategoryRequestAsync(dynamic request, int? excludeId)
        {
            string name = request.Name;
            int minAge = request.MinAge;
            int maxAge = request.MaxAge;

            var existingByName = await _context.Set<Category>()
                .FirstOrDefaultAsync(c => c.Name.ToLower() == name.ToLower() && 
                                    (excludeId == null || c.Id != excludeId));

            if (existingByName != null)
            {
                throw new UserException("Category with this name already exists.");
            }

            var overlappingCategory = await _context.Set<Category>()
                .FirstOrDefaultAsync(c => 
                    (excludeId == null || c.Id != excludeId) &&
                    minAge <= c.MaxAge && 
                    maxAge >= c.MinAge);

            if (overlappingCategory != null)
            {
                throw new UserException($"Age range overlaps with existing category '{overlappingCategory.Name}' ({overlappingCategory.MinAge}-{overlappingCategory.MaxAge}).");
            }

            if (minAge >= maxAge)
            {
                throw new UserException("Minimum age must be less than maximum age.");
            }
        }
    }
}
