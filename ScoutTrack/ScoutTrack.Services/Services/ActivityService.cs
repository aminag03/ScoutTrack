using MapsterMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services.ActivityStateMachine;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class ActivityService : BaseCRUDService<ActivityResponse, ActivitySearchObject, Activity, ActivityUpsertRequest, ActivityUpsertRequest>, IActivityService
    {
        private readonly ScoutTrackDbContext _context;
        protected readonly BaseActivityState _baseActivityState;

        public ActivityService(ScoutTrackDbContext context, IMapper mapper, BaseActivityState baseActivityState) : base(context, mapper)
        {
            _context = context;
            _baseActivityState = baseActivityState;
        }

        protected override IQueryable<Activity> ApplyFilter(IQueryable<Activity> query, ActivitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(a => a.Title.Contains(search.Title));
            }
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => a.Title.Contains(search.FTS) || a.Description.Contains(search.FTS));
            }
            return query;
        }

        public override async Task<ActivityResponse> CreateAsync(ActivityUpsertRequest request)
        {
            var baseState = _baseActivityState.GetActivityState(nameof(InitialActivityState));

            var entity = new Activity();
            _mapper.Map(request, entity);
            await BeforeInsert(entity, request);

            var result = await baseState.CreateAsync(request);
            return result;

            // return await base.CreateAsync(request);
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            _mapper.Map(request, entity);
            await BeforeUpdate(entity, request);

            return await baseState.UpdateAsync(id, request);
;
            // return await base.UpdateAsync(id, request);
        }

        protected override async Task BeforeInsert(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        protected override async Task BeforeUpdate(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        public async Task<ActivityResponse> ActivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.ActivateAsync(id);
        }

        public async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.DeactivateAsync(id);
        }
    }
} 