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
    public class InitialActivityState : BaseActivityState
    {
        public InitialActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> CreateAsync(ActivityUpsertRequest request)
        {
            var entity = new Activity();
            _mapper.Map(request, entity);

            entity.ActivityState = nameof(DraftActivityState);
            entity.ImagePath = request.ImagePath ?? string.Empty;

            _context.Activities.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
