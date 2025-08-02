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
                    var initialState = _serviceProvider.GetService<InitialActivityState>();
                    if (initialState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return initialState;
                    
                case nameof(DraftActivityState):
                    var draftState = _serviceProvider.GetService<DraftActivityState>();
                    if (draftState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return draftState;
                    
                case nameof(ActiveActivityState):
                    var activeState = _serviceProvider.GetService<ActiveActivityState>();
                    if (activeState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return activeState;
                    
                case nameof(RegistrationsClosedActivityState):
                    var registrationsClosedState = _serviceProvider.GetService<RegistrationsClosedActivityState>();
                    if (registrationsClosedState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return registrationsClosedState;
                    
                case nameof(FinishedActivityState):
                    var finishedState = _serviceProvider.GetService<FinishedActivityState>();
                    if (finishedState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return finishedState;
                    
                case nameof(CancelledActivityState):
                    var cancelledState = _serviceProvider.GetService<CancelledActivityState>();
                    if (cancelledState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return cancelledState;

                default:
                    throw new Exception($"State {stateName} not defined.");
            }
        }
    }
}
