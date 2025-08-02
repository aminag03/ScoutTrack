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
    public class FinishedActivityState : BaseActivityState
    {
        public FinishedActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper)
            : base(serviceProvider, context, mapper) { }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            throw new UserException("Cannot modify a finished activity.");
        }

        public override async Task<ActivityResponse> ActivateAsync(int id)
        {
            throw new UserException("Cannot activate a finished activity.");
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            throw new UserException("Cannot deactivate a finished activity.");
        }
    }
} 