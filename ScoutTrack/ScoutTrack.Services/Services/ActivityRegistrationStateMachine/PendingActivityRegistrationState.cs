using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services.ActivityRegistrationStateMachine
{
    public class PendingActivityRegistrationState : BaseActivityRegistrationState
    {
        public PendingActivityRegistrationState(IServiceProvider serviceProvider, ScoutTrackDbContext context, IMapper mapper) 
            : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ActivityRegistrationResponse> CreateAsync(ActivityRegistrationUpsertRequest request)
        {
            // This method is now deprecated as CreateForUserAsync handles the creation
            throw new UserException("Use CreateForUserAsync instead of CreateAsync for activity registrations.");
        }

        public override async Task<ActivityRegistrationResponse> ApproveAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Member)
                .Include(ar => ar.Activity)
                .FirstOrDefaultAsync(ar => ar.Id == id);
            
            if (entity == null)
                throw new Exception("Activity registration not found");

            entity.Status = RegistrationStatus.Approved;
            await _context.SaveChangesAsync();

            try
            {
                if (entity.Member != null && entity.Activity != null)
                {
                    var notificationMessage = $"Vaša prijava za aktivnost '{entity.Activity.Title}' je odobrena!";

                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = new List<int> { entity.MemberId },
                            SenderId = entity.MemberId,
                            CreatedAt = DateTime.Now,
                            ActivityId = entity.ActivityId.ToString(),
                            NotificationType = "RegistrationApproved"
                        };

                        await notificationPublisher.PublishNotificationAsync(notificationEvent);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending notification for registration approval: {ex.Message}");
            }

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }

        public override async Task<ActivityRegistrationResponse> RejectAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Member)
                .Include(ar => ar.Activity)
                .FirstOrDefaultAsync(ar => ar.Id == id);
            
            if (entity == null)
                throw new Exception("Activity registration not found");

            entity.Status = RegistrationStatus.Rejected;
            await _context.SaveChangesAsync();

            try
            {
                if (entity.Member != null && entity.Activity != null)
                {
                    var notificationMessage = $"Vaša prijava za aktivnost '{entity.Activity.Title}' je odbijena.";

                    var notificationPublisher = _serviceProvider.GetService(typeof(INotificationPublisherService)) as INotificationPublisherService;
                    if (notificationPublisher != null)
                    {
                        var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                        {
                            Message = notificationMessage,
                            UserIds = new List<int> { entity.MemberId },
                            SenderId = entity.MemberId,
                            CreatedAt = DateTime.Now,
                            ActivityId = entity.ActivityId.ToString(),
                            NotificationType = "RegistrationRejected"
                        };

                        await notificationPublisher.PublishNotificationAsync(notificationEvent);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending notification for registration rejection: {ex.Message}");
            }

            return _mapper.Map<ActivityRegistrationResponse>(entity);
        }
    }
} 