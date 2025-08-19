using System;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Requests
{
    public class MemberBadgeUpsertRequest
    {
        public int MemberId { get; set; }
        public int BadgeId { get; set; }
        public MemberBadgeStatus Status { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}
