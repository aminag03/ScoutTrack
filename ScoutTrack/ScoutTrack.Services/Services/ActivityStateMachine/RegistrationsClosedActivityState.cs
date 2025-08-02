using MapsterMapper;
using ScoutTrack.Model.Exceptions;
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
    public class RegistrationsClosedActivityState : BaseActivityState
    {
        public RegistrationsClosedActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper)
            : base(serviceProvider, context, mapper) { }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            throw new UserException("Cannot edit activity once registrations are closed.");
        }

        public override async Task<ActivityResponse> ActivateAsync(int id)
        {
            throw new UserException("Already active, but registrations are closed.");
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(CancelledActivityState);
            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public async Task<ActivityResponse> FinishAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(FinishedActivityState);
            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
} 