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
    public class RegistrationsOpenActivityState : BaseActivityState
    {
        public RegistrationsOpenActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
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
                    
                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = registeredUserIds,
                            SenderId = currentUserId,
                            CreatedAt = DateTime.Now,
                            ActivityId = id.ToString(),
                            NotificationType = "ActivityUpdate"
                        };
                        
                        await notificationPublisher.PublishNotificationAsync(notificationEvent);
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

            // Send notification to registered members
            try
            {
                var registeredUserIds = await GetRegisteredMemberUserIdsAsync(id);
                
                if (registeredUserIds.Any())
                {
                    var notificationMessage = $"Aktivnost '{entity.Title}' je otkazana.";
                    
                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = registeredUserIds,
                            SenderId = entity.TroopId,
                            CreatedAt = DateTime.Now,
                            ActivityId = id.ToString(),
                            NotificationType = "ActivityStateChanged"
                        };
                        
                        await notificationPublisher.PublishNotificationAsync(notificationEvent);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending notification for activity cancellation: {ex.Message}");
            }

            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            Console.WriteLine($"RegistrationsOpenActivityState: Closing registrations for activity {id}. Current state: {entity.ActivityState}");
            
            var now = DateTime.Now;
            if (entity.StartTime.HasValue && entity.StartTime.Value < now)
            {
                throw new UserException("Cannot close registrations: start time is in the past.");
            }
            if (entity.EndTime.HasValue && entity.EndTime.Value < now)
            {
                throw new UserException("Cannot close registrations: end time is in the past.");
            }
            
            entity.ActivityState = nameof(RegistrationsClosedActivityState);
            Console.WriteLine($"RegistrationsOpenActivityState: Setting new state to: {entity.ActivityState}");

            await _context.SaveChangesAsync();
            Console.WriteLine($"RegistrationsOpenActivityState: Saved changes. Final state: {entity.ActivityState}");

            // Send notification to registered members
            try
            {
                Console.WriteLine($"🔔 Attempting to send notification for registration closure...");
                var registeredUserIds = await GetRegisteredMemberUserIdsAsync(id);
                
                if (registeredUserIds.Any())
                {
                    var notificationMessage = $"Prijave za aktivnost '{entity.Title}' su zatvorene.";
                    
                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        Console.WriteLine($"🔔 NotificationPublisher found, publishing notification...");
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = registeredUserIds,
                            SenderId = entity.TroopId,
                            CreatedAt = DateTime.Now,
                            ActivityId = id.ToString(),
                            NotificationType = "ActivityStateChanged"
                        };
                        
                        await notificationPublisher.PublishNotificationAsync(notificationEvent);
                        Console.WriteLine($"✅ Notification published successfully");
                    }
                    else
                    {
                        Console.WriteLine($"❌ NotificationPublisher not found in service provider");
                    }
                }
                else
                {
                    Console.WriteLine($"⚠️ No registered members found for activity {id}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error sending notification for registration closure: {ex.Message}");
                Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
            }
            
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
