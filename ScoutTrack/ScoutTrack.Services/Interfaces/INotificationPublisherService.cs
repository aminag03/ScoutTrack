using ScoutTrack.Model.Events;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface INotificationPublisherService
    {
        Task PublishNotificationAsync(NotificationEvent notificationEvent);
    }
}

