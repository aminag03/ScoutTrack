using System;
using System.Threading;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public interface IRabbitMQService
    {
        Task PublishAsync<T>(T message, string topic) where T : class;
        Task SubscribeAsync<T>(string subscriptionId, Func<T, Task> handler, string topic, CancellationToken cancellationToken = default) where T : class;
        void Dispose();
    }
}
