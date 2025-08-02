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
            entity.ActivityState = nameof(CancelledActivityState);

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            Console.WriteLine($"ActiveActivityState: Closing registrations for activity {id}. Current state: {entity.ActivityState}");
            
            entity.ActivityState = nameof(RegistrationsClosedActivityState);
            Console.WriteLine($"ActiveActivityState: Setting new state to: {entity.ActivityState}");

            await _context.SaveChangesAsync();
            Console.WriteLine($"ActiveActivityState: Saved changes. Final state: {entity.ActivityState}");
            
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
