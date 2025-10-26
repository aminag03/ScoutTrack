using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class DraftActivityState : BaseActivityState
    {
        public DraftActivityState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityResponse> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            _mapper.Map(request, entity);
            entity.ImagePath = string.IsNullOrWhiteSpace(request.ImagePath) ? "" : request.ImagePath;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> ActivateAsync(int id)
        {
            var entity = await _context.Activities
                .Include(a => a.Troop)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            var now = DateTime.Now;
            if (entity.StartTime.HasValue && entity.StartTime.Value < now)
            {
                throw new UserException("Cannot activate activity: start time is in the past.");
            }
            if (entity.EndTime.HasValue && entity.EndTime.Value < now)
            {
                throw new UserException("Cannot activate activity: end time is in the past.");
            }
            
            entity.ActivityState = nameof(RegistrationsOpenActivityState);

            await _context.SaveChangesAsync();

            // Send notification to troop that activity is now open for registrations
            try
            {
                Console.WriteLine($"🔔 DraftActivityState.ActivateAsync: Attempting to send notification...");
                if (entity.Troop != null)
                {
                    var notificationMessage = $"Aktivnost '{entity.Title}' je sada otvorena za prijave.";

                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        Console.WriteLine($"🔔 NotificationPublisher found, publishing notification...");
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = new List<int> { entity.TroopId },
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
                    Console.WriteLine($"⚠️ Troop is null for activity {id}");
                }
            }
            catch (Exception ex)
            {
                // Log error but don't fail the state transition
                Console.WriteLine($"❌ Error sending notification for activity activation: {ex.Message}");
                Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
            }

            return _mapper.Map<ActivityResponse>(entity);
        }

        public override async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            entity.ActivityState = nameof(CancelledActivityState);
            entity.Title = entity.Title + " - Cancelled from draft";

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }
    }
}
