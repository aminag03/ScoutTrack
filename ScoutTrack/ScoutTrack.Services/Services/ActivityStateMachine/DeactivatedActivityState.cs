using MapsterMapper;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityStateMachine
{
    public class DeactivatedActivityState : BaseActivityState
    {
        public DeactivatedActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(DraftActivityState);

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
