using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
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
    }
} 