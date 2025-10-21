using EasyNetQ;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class RabbitMQService : IRabbitMQService, IDisposable
    {
        private readonly IBus _bus;
        private readonly ILogger<RabbitMQService> _logger;
        private bool _disposed = false;

        public RabbitMQService(IConfiguration configuration, ILogger<RabbitMQService> logger)
        {
            _logger = logger;
            var connectionString = configuration["RabbitMQ:ConnectionString"] ?? "host=localhost";
            _bus = RabbitHutch.CreateBus(connectionString);
            _logger.LogInformation("RabbitMQ service initialized with connection: {ConnectionString}", connectionString);
        }

        public async Task PublishAsync<T>(T message, string topic) where T : class
        {
            try
            {
                await _bus.PubSub.PublishAsync(message, topic);
                _logger.LogDebug("Message published to topic: {Topic}", topic);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error publishing message to topic: {Topic}", topic);
                throw;
            }
        }

        public async Task SubscribeAsync<T>(string subscriptionId, Func<T, Task> handler, string topic, CancellationToken cancellationToken = default) where T : class
        {
            try
            {
                await _bus.PubSub.SubscribeAsync<T>(subscriptionId, async (message, ct) => await handler(message), configure => configure.WithTopic(topic), cancellationToken);
                _logger.LogInformation("Subscribed to topic: {Topic} with subscription ID: {SubscriptionId}", topic, subscriptionId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error subscribing to topic: {Topic}", topic);
                throw;
            }
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _bus?.Dispose();
                _disposed = true;
                _logger.LogInformation("RabbitMQ service disposed");
            }
        }
    }
}
