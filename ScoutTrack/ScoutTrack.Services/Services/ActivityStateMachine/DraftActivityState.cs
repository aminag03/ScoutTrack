using MapsterMapper;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityStateMachine
{
    public class DraftActivityState : BaseActivityState
    {
        public DraftActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            _mapper.Map(request, entity);
            entity.ImagePath = string.IsNullOrWhiteSpace(request.ImagePath) ? "" : request.ImagePath;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> ActivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(ActiveActivityState);

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(CancelledActivityState);
            entity.Title = entity.Title + " - Cancelled from draft";

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
