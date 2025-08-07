using MapsterMapper;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityRegistrationStateMachine
{
    public class PendingActivityRegistrationState : BaseActivityRegistrationState
    {
        public PendingActivityRegistrationState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) 
            : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityRegistrationResponse> CreateAsync(ActivityRegistrationUpsertRequest request)
        {
            // This method is now deprecated as CreateForUserAsync handles the creation
            throw new UserException("Use CreateForUserAsync instead of CreateAsync for activity registrations.");
        }

        public override async Task<ActivityRegistrationResponse> ApproveAsync(int id)
        {
            var entity = await _context.ActivityRegistrations.FindAsync(id);
            if (entity == null)
                throw new Exception("Activity registration not found");

            entity.Status = RegistrationStatus.Approved;
            await _context.SaveChangesAsync();

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }

        public override async Task<ActivityRegistrationResponse> RejectAsync(int id, string reason = "")
        {
            var entity = await _context.ActivityRegistrations.FindAsync(id);
            if (entity == null)
                throw new Exception("Activity registration not found");

            entity.Status = RegistrationStatus.Rejected;
            if (!string.IsNullOrEmpty(reason))
                entity.Notes = reason;

            await _context.SaveChangesAsync();

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }

        public override async Task<ActivityRegistrationResponse> CancelAsync(int id)
        {
            var entity = await _context.ActivityRegistrations.FindAsync(id);
            if (entity == null)
                throw new Exception("Activity registration not found");

            entity.Status = RegistrationStatus.Cancelled;
            await _context.SaveChangesAsync();

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }
    }
} 