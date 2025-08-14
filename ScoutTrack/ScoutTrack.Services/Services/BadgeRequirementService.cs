using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class BadgeRequirementService : BaseCRUDService<BadgeRequirementResponse, BadgeRequirementSearchObject, BadgeRequirement, BadgeRequirementUpsertRequest, BadgeRequirementUpsertRequest>, IBadgeRequirementService
    {
        private readonly ScoutTrackDbContext _context;

        public BadgeRequirementService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper) 
        {
            _context = context;
        }

        public override async Task<PagedResult<BadgeRequirementResponse>> GetAsync(BadgeRequirementSearchObject search)
        {
            var query = _context.Set<BadgeRequirement>().AsQueryable();
            query = ApplyFilter(query, search);
            query = query.Include(br => br.Badge);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
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

            var list = await query.ToListAsync();
            return new PagedResult<BadgeRequirementResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<BadgeRequirementResponse?> GetByIdAsync(int id)
        {
            var query = _context.Set<BadgeRequirement>().AsQueryable();
            query = query.Where(br => br.Id == id);
            query = query.Include(br => br.Badge);
            
            var entity = await query.FirstOrDefaultAsync();
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override IQueryable<BadgeRequirement> ApplyFilter(IQueryable<BadgeRequirement> query, BadgeRequirementSearchObject search)
        {
            if (search.BadgeId.HasValue)
            {
                query = query.Where(br => br.BadgeId == search.BadgeId.Value);
            }

            if (!string.IsNullOrEmpty(search.Description))
            {
                query = query.Where(br => br.Description.Contains(search.Description));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(br => br.Description.Contains(search.FTS));
            }
            return query;
        }

        protected override BadgeRequirementResponse MapToResponse(BadgeRequirement entity)
        {
            var response = _mapper.Map<BadgeRequirementResponse>(entity);
            response.BadgeName = entity.Badge?.Name ?? string.Empty;
            return response;
        }

        protected override async Task BeforeInsert(BadgeRequirement entity, BadgeRequirementUpsertRequest request)
        {
            // Check if badge exists
            if (!await _context.Badges.AnyAsync(b => b.Id == request.BadgeId))
                throw new UserException("Badge with this ID does not exist.");

            // Check if requirement with same description already exists for this badge
            if (await _context.BadgeRequirements.AnyAsync(br => br.BadgeId == request.BadgeId && br.Description == request.Description))
                throw new UserException("Requirement with this description already exists for this badge.");

            // Check if badge already has maximum number of requirements (20)
            var currentRequirementCount = await _context.BadgeRequirements.CountAsync(br => br.BadgeId == request.BadgeId);
            if (currentRequirementCount >= 20)
                throw new UserException("Badge already has maximum number of requirements (20). Cannot add more requirements.");
        }

        protected override async Task BeforeUpdate(BadgeRequirement entity, BadgeRequirementUpsertRequest request)
        {
            // Check if badge exists
            if (!await _context.Badges.AnyAsync(b => b.Id == request.BadgeId))
                throw new UserException("Badge with this ID does not exist.");

            if (await _context.BadgeRequirements.AnyAsync(br => br.BadgeId == request.BadgeId && br.Description == request.Description && br.Id != entity.Id))
                throw new UserException("Requirement with this description already exists for this badge.");
        }
    }
}
