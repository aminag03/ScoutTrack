using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.SearchObjects
{
    public class FriendshipSearchObject : BaseSearchObject
    {
        public int? RequesterId { get; set; }
        public int? ResponderId { get; set; }
        public FriendshipStatus? Status { get; set; }
        public int? MemberId { get; set; } // For finding friendships where a specific member is either requester or responder
    }
}
