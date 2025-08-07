using MapsterMapper;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityRegistrationStateMachine
{
    public class RejectedActivityRegistrationState : BaseActivityRegistrationState
    {
        public RejectedActivityRegistrationState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) 
            : base(serviceProvider, context, mapper)
        {
        }

        // Rejected registrations can be updated to change status back to pending for reconsideration
        public override async Task<ActivityRegistrationResponse> UpdateAsync(int id, ActivityRegistrationUpsertRequest request)
        {
            var entity = await _context.ActivityRegistrations.FindAsync(id);
            if (entity == null)
                throw new Exception("Activity registration not found");

            // Allow changing status back to pending for reconsideration
            // Since the request no longer contains Status, we'll allow the update to proceed
            // and let the service layer handle the status change logic
            entity.Notes = request.Notes;
            await _context.SaveChangesAsync();

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }
    }
} 