using MapsterMapper;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ScoutTrack.Model.Exceptions;
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

        public virtual async Task<ActivityResponse> UpdateAsync(int id, ActivityUpdateRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityResponse> UpdateAsync(int id, ActivityUpdateRequest request, int currentUserId)
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

        public virtual async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            throw new UserException("Not allowed");
        }

        public virtual async Task<ActivityResponse> FinishAsync(int id)
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
                    
                case nameof(RegistrationsOpenActivityState):
                    var activeState = _serviceProvider.GetService<RegistrationsOpenActivityState>();
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

        protected bool HasMajorFieldChanges(Activity original, ActivityUpdateRequest request)
        {
            return original.StartTime != request.StartTime ||
                   original.EndTime != request.EndTime ||
                   original.CityId != request.CityId ||
                   original.LocationName != request.LocationName ||
                   original.Fee != request.Fee;
        }

        protected bool HasMinorFieldChanges(Activity original, ActivityUpdateRequest request)
        {
            return original.Title != request.Title ||
                   original.Description != request.Description ||
                   original.Summary != request.Summary ||
                   original.ImagePath != request.ImagePath;
        }

        protected string CreateChangeNotificationMessage(Activity original, ActivityUpdateRequest request, string changeReason)
        {
            var changes = new List<string>();

            if (original.StartTime != request.StartTime)
            {
                var oldTime = original.StartTime?.ToString("dd.MM.yyyy HH:mm") ?? "Nije postavljeno";
                var newTime = request.StartTime?.ToString("dd.MM.yyyy HH:mm") ?? "Nije postavljeno";
                changes.Add($"Početak: {oldTime} → {newTime}");
            }

            if (original.EndTime != request.EndTime)
            {
                var oldTime = original.EndTime?.ToString("dd.MM.yyyy HH:mm") ?? "Nije postavljeno";
                var newTime = request.EndTime?.ToString("dd.MM.yyyy HH:mm") ?? "Nije postavljeno";
                changes.Add($"Kraj: {oldTime} → {newTime}");
            }

            if (original.CityId != request.CityId)
            {
                changes.Add($"Grad: ID {original.CityId} → ID {request.CityId}");
            }

            if (original.LocationName != request.LocationName)
            {
                changes.Add($"Lokacija: {original.LocationName} → {request.LocationName}");
            }

            if (original.Fee != request.Fee)
            {
                var oldFee = original.Fee?.ToString("C") ?? "Besplatno";
                var newFee = request.Fee?.ToString("C") ?? "Besplatno";
                changes.Add($"Kotizacija: {oldFee} → {newFee}");
            }

            var changesText = string.Join(", ", changes);
            return $"Aktivnost '{original.Title}' je ažurirana. Promjene: {changesText}. Razlog: {changeReason}";
        }

        protected async Task<List<int>> GetRegisteredMemberUserIdsAsync(int activityId)
        {
            return await _context.ActivityRegistrations
                .Where(ar => ar.ActivityId == activityId && 
                           (ar.Status == Common.Enums.RegistrationStatus.Approved || 
                            ar.Status == Common.Enums.RegistrationStatus.Pending))
                .Select(ar => ar.Member.Id)
                .ToListAsync();
        }
    }
}
