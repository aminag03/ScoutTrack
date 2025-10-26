using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class ActivityTypeService : BaseCRUDService<ActivityTypeResponse, ActivityTypeSearchObject, ActivityType, ActivityTypeUpsertRequest, ActivityTypeUpsertRequest>, IActivityTypeService
    {
        private readonly ScoutTrackDbContext _context;

        public ActivityTypeService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<ActivityType> ApplyFilter(IQueryable<ActivityType> query, ActivityTypeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(at => at.Name.Contains(search.Name));
            }
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(at => at.Name.Contains(search.FTS) || at.Description.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(ActivityType entity, ActivityTypeUpsertRequest request)
        {
            if (await _context.ActivityTypes.AnyAsync(at => at.Name == request.Name))
                throw new UserException("ActivityType with this name already exists.");
        }

        protected override async Task BeforeUpdate(ActivityType entity, ActivityTypeUpsertRequest request)
        {
            if (await _context.ActivityTypes.AnyAsync(at => at.Name == request.Name && at.Id != entity.Id))
                throw new UserException("ActivityType with this name already exists.");
        }

        protected override async Task BeforeDelete(ActivityType entity)
        {
            if (await _context.Activities.AnyAsync(a => a.ActivityTypeId == entity.Id))
                throw new UserException("Cannot delete ActivityType: there are activities using this type.");
        }

        protected override void MapUpdateToEntity(ActivityType entity, ActivityTypeUpsertRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
            base.MapUpdateToEntity(entity, request);
        }

        public override async Task<PagedResult<ActivityTypeResponse>> GetAsync(ActivityTypeSearchObject search)
        {
            var baseQuery = _context.Set<ActivityType>().AsQueryable();
            baseQuery = ApplyFilter(baseQuery, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await baseQuery.CountAsync();
            }

            var entities = await baseQuery.ToListAsync();

            var responseList = entities.Select(at => new ActivityTypeResponse
            {
                Id = at.Id,
                Name = at.Name,
                Description = at.Description,
                CreatedAt = at.CreatedAt,
                UpdatedAt = at.UpdatedAt,
                ActivityCount = _context.Activities.Count(a => a.ActivityTypeId == at.Id)
            }).ToList();

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy.ToLower();
                var descending = orderBy.StartsWith("-");
                if (descending)
                {
                    orderBy = orderBy.Substring(1);
                }

                responseList = orderBy switch
                {
                    "name" => descending
                        ? responseList.OrderByDescending(x => x.Name).ToList()
                        : responseList.OrderBy(x => x.Name).ToList(),
                    "createdat" => descending
                        ? responseList.OrderByDescending(x => x.CreatedAt).ToList()
                        : responseList.OrderBy(x => x.CreatedAt).ToList(),
                    "updatedat" => descending
                        ? responseList.OrderByDescending(x => x.UpdatedAt).ToList()
                        : responseList.OrderBy(x => x.UpdatedAt).ToList(),
                    "activitycount" => descending
                        ? responseList.OrderByDescending(x => x.ActivityCount).ToList()
                        : responseList.OrderBy(x => x.ActivityCount).ToList(),
                    _ => responseList
                };
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                responseList = responseList
                    .Skip(search.Page.Value * search.PageSize.Value)
                    .Take(search.PageSize.Value)
                    .ToList();
            }

            return new PagedResult<ActivityTypeResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }
    }
} 