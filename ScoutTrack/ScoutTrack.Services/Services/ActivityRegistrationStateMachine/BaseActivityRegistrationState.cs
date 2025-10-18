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

namespace ScoutTrack.Services.Services.ActivityRegistrationStateMachine
{
    public class BaseActivityRegistrationState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly ScoutTrackDbContext _context;
        protected readonly IMapper _mapper;
        
        public BaseActivityRegistrationState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<ActivityRegistrationResponse> CreateAsync(ActivityRegistrationUpsertRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityRegistrationResponse> UpdateAsync(int id, ActivityRegistrationUpsertRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityRegistrationResponse> ApproveAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityRegistrationResponse> RejectAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityRegistrationResponse> CompleteAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public BaseActivityRegistrationState GetActivityRegistrationState(string stateName)
        {
            switch (stateName)
            {
                case nameof(PendingActivityRegistrationState):
                    var pendingState = _serviceProvider.GetService<PendingActivityRegistrationState>();
                    if (pendingState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return pendingState;
                    
                case nameof(ApprovedActivityRegistrationState):
                    var approvedState = _serviceProvider.GetService<ApprovedActivityRegistrationState>();
                    if (approvedState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return approvedState;
                    
                case nameof(RejectedActivityRegistrationState):
                    var rejectedState = _serviceProvider.GetService<RejectedActivityRegistrationState>();
                    if (rejectedState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return rejectedState;
                    
                case nameof(CompletedActivityRegistrationState):
                    var completedState = _serviceProvider.GetService<CompletedActivityRegistrationState>();
                    if (completedState == null) throw new Exception($"State {stateName} is not registered in DI container.");
                    return completedState;

                default:
                    throw new Exception($"State {stateName} not defined.");
            }
        }
    }
} 