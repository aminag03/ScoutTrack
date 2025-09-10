using MapsterMapper;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityStateMachine
{
    public class ActiveActivityState : BaseActivityState
    {
        public ActiveActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpdateRequest request)
        {
            return await UpdateAsync(id, request, 0); // Default to 0 if no user ID provided
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpdateRequest request, int currentUserId)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            bool hasMajorChanges = HasMajorFieldChanges(entity, request);
            
            if (hasMajorChanges)
            {
                if (string.IsNullOrWhiteSpace(request.ChangeReason))
                {
                    throw new UserException("ChangeReason is required when making major field changes (StartTime, EndTime, CityId, LocationName, Fee) to active activities.");
                }

                var registeredUserIds = await GetRegisteredMemberUserIdsAsync(id);
                
                if (registeredUserIds.Any())
                {
                    var notificationMessage = CreateChangeNotificationMessage(entity, request, request.ChangeReason);
                    
                    var notificationService = _serviceProvider.GetService(typeof(INotificationService)) as INotificationService;
                    if (notificationService != null)
                    {
                        var notificationRequest = new NotificationUpsertRequest
                        {
                            Message = notificationMessage,
                            UserIds = registeredUserIds
                        };
                        
                        await notificationService.SendNotificationsToUsersAsync(notificationRequest, currentUserId);
                    }
                }
            }

            _mapper.Map(request, entity);
            entity.ImagePath = string.IsNullOrWhiteSpace(request.ImagePath) ? "" : request.ImagePath;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(CancelledActivityState);

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            Console.WriteLine($"ActiveActivityState: Closing registrations for activity {id}. Current state: {entity.ActivityState}");
            
            entity.ActivityState = nameof(RegistrationsClosedActivityState);
            Console.WriteLine($"ActiveActivityState: Setting new state to: {entity.ActivityState}");

            await _context.SaveChangesAsync();
            Console.WriteLine($"ActiveActivityState: Saved changes. Final state: {entity.ActivityState}");
            
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
