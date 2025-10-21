using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Events;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services;
using System;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class NotificationPublisherService : INotificationPublisherService
    {
        private readonly IRabbitMQService _rabbitMQService;
        private readonly ILogger<NotificationPublisherService> _logger;

        public NotificationPublisherService(IRabbitMQService rabbitMQService, ILogger<NotificationPublisherService> logger)
        {
            _rabbitMQService = rabbitMQService;
            _logger = logger;
        }

        public async Task PublishNotificationAsync(NotificationEvent notificationEvent)
        {
            try
            {
                await _rabbitMQService.PublishAsync(notificationEvent, "notification.created");

                _logger.LogInformation(
                    "Notification published to RabbitMQ: Message='{Message}', SenderId={SenderId}, UserCount={UserCount}",
                    notificationEvent.Message,
                    notificationEvent.SenderId,
                    notificationEvent.UserIds?.Count ?? 0);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error publishing notification to RabbitMQ");
                throw;
            }
        }
    }
}

