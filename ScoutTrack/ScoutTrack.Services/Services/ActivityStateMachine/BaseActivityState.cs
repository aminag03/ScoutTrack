using MapsterMapper;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.DependencyInjection;
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
    public class BaseActivityState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly ScoutTrackDbContext _context;
        protected readonly IMapper _mapper;
        public BaseActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<ActivityResponse> CreateAsync(ActivityUpsertRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityResponse> ActivateAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityResponse> DeactivateAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public BaseActivityState GetActivityState(string stateName)
        {
            switch (stateName)
            {
                case nameof(InitialActivityState):
                    return _serviceProvider.GetService<InitialActivityState>();
                case nameof(DraftActivityState):
                    return _serviceProvider.GetService<DraftActivityState>();
                case nameof(ActiveActivityState):
                    return _serviceProvider.GetService<ActiveActivityState>();
                case nameof(DeactivatedActivityState):
                    return _serviceProvider.GetService<DeactivatedActivityState>();

                default:
                    throw new Exception($"State {stateName} not defined.");
            }
        }
    }
}
