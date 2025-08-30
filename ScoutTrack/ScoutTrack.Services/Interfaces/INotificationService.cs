using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface INotificationService : ICRUDService<NotificationResponse, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>
    {
        Task<List<NotificationResponse>> SendNotificationsToUsersAsync(NotificationUpsertRequest request, int senderId);
        Task<bool> MarkAsReadAsync(int id);
        Task<bool> MarkAllAsReadAsync(int userId);
        Task<int> GetUnreadCountAsync(int userId);
        Task<PagedResult<NotificationResponse>> GetForUserAsync(ClaimsPrincipal user, NotificationSearchObject search);
        Task<bool> MarkAsReadForUserAsync(ClaimsPrincipal user, int id);
        Task<bool> MarkAllAsReadForUserAsync(ClaimsPrincipal user);
        Task<int> GetUnreadCountForUserAsync(ClaimsPrincipal user);
        Task<bool> DeleteAllNotificationsForUserAsync(ClaimsPrincipal user);
    }
}
