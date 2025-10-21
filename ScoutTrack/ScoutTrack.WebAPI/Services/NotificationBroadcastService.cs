using EasyNetQ;
using Microsoft.AspNetCore.SignalR;
using ScoutTrack.Model.Events;
using ScoutTrack.WebAPI.Hubs;
using ScoutTrack.Services.Services;

namespace ScoutTrack.WebAPI.Services
{
    public class NotificationBroadcastService : BackgroundService
    {
        private readonly IRabbitMQService _rabbitMQService;
        private readonly IHubContext<NotificationHub> _hubContext;
        private readonly ILogger<NotificationBroadcastService> _logger;

        public NotificationBroadcastService(
            IRabbitMQService rabbitMQService,
            IHubContext<NotificationHub> hubContext,
            ILogger<NotificationBroadcastService> logger)
        {
            _rabbitMQService = rabbitMQService;
            _hubContext = hubContext;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Starting Notification Broadcast Service...");

            try
            {
                _logger.LogInformation("Setting up RabbitMQ subscription...");
                await _rabbitMQService.SubscribeAsync<NotificationEvent>(
                    "notification_broadcaster",
                    async notification =>
                    {
                        try
                        {
                            _logger.LogInformation($"📨 Received notification for broadcast: {notification.Message}");
                            _logger.LogInformation($"📨 User IDs: [{string.Join(", ", notification.UserIds)}]");
                            _logger.LogInformation($"📨 Sender ID: {notification.SenderId}");

                            foreach (var userId in notification.UserIds)
                            {
                                var groupName = $"user_{userId}";
                                _logger.LogInformation($"📤 Broadcasting to SignalR group: {groupName}");

                                await _hubContext.Clients.Group(groupName)
                                    .SendAsync("ReceiveNotification", new
                                    {
                                        message = notification.Message,
                                        senderId = notification.SenderId,
                                        createdAt = notification.CreatedAt,
                                        activityId = notification.ActivityId,
                                        notificationType = notification.NotificationType
                                    });

                                _logger.LogInformation($"✅ Broadcasted to group: {groupName}");
                            }

                            _logger.LogInformation($"🎉 Successfully broadcasted notification to {notification.UserIds.Count} users via SignalR");
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, $"Error broadcasting notification: {ex.Message}");
                        }
                    },
                    "notification.created",
                    stoppingToken
                );

                _logger.LogInformation("✅ RabbitMQ consumer started for real-time notifications");

                await Task.Delay(Timeout.Infinite, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error starting Notification Broadcast Service");
            }
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Stopping Notification Broadcast Service...");
            await base.StopAsync(cancellationToken);
        }
    }
}
