using System;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Responses
{
    public class MemberBadgeResponse
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberFirstName { get; set; } = string.Empty;
        public string MemberLastName { get; set; } = string.Empty;
        public string MemberProfilePictureUrl { get; set; } = string.Empty;
        public int BadgeId { get; set; }
        public string BadgeName { get; set; } = string.Empty;
        public string BadgeImageUrl { get; set; } = string.Empty;
        public MemberBadgeStatus Status { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
