using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IFriendshipService : ICRUDService<FriendshipResponse, FriendshipSearchObject, FriendshipUpsertRequest, FriendshipUpsertRequest>
    {
        Task<FriendshipResponse?> SendFriendRequestAsync(int requesterId, int responderId);
        Task<FriendshipResponse?> AcceptFriendRequestAsync(int friendshipId, int responderId);
        Task<bool> RejectFriendRequestAsync(int friendshipId, int responderId);
        Task<bool> UnfriendAsync(int friendshipId, int memberId);
        Task<bool> CancelFriendRequestAsync(int friendshipId, int requesterId);
    }
}
