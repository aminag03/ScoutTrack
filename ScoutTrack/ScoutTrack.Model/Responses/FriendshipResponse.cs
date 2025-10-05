using System;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Responses
{
    public class FriendshipResponse
    {
        public int Id { get; set; }
        public int RequesterId { get; set; }
        public string RequesterUsername { get; set; } = string.Empty;
        public string RequesterFirstName { get; set; } = string.Empty;
        public string RequesterLastName { get; set; } = string.Empty;
        public string RequesterProfilePictureUrl { get; set; } = string.Empty;
        public int ResponderId { get; set; }
        public string ResponderUsername { get; set; } = string.Empty;
        public string ResponderFirstName { get; set; } = string.Empty;
        public string ResponderLastName { get; set; } = string.Empty;
        public string ResponderProfilePictureUrl { get; set; } = string.Empty;
        public DateTime RequestedAt { get; set; }
        public DateTime? RespondedAt { get; set; }
        public FriendshipStatus Status { get; set; }
        public string StatusName { get; set; } = string.Empty;
    }
}
