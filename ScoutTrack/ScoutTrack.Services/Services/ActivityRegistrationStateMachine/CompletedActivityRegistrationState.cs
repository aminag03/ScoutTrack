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
    public class CompletedActivityRegistrationState : BaseActivityRegistrationState
    {
        public CompletedActivityRegistrationState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) 
            : base(serviceProvider, context, mapper)
        {
        }

        // Completed registrations are final and cannot be changed
        // Only allow viewing/reading operations
    }
} 