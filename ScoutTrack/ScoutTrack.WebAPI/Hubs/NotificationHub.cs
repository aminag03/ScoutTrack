using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.Authorization;
using ScoutTrack.Services.Interfaces;
using System.Threading.Tasks;

namespace ScoutTrack.WebAPI.Hubs
{
    [Authorize]
    public class NotificationHub : Hub, INotificationHub
    {
        public async Task JoinUserGroup(int userId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
        }

        public async Task LeaveUserGroup(int userId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user_{userId}");
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
        }
    }
}

