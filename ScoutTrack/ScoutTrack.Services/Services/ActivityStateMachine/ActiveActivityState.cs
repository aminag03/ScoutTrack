using MapsterMapper;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityStateMachine
{
    public class ActiveActivityState : BaseActivityState
    {
        public ActiveActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(DeactivatedActivityState);

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
