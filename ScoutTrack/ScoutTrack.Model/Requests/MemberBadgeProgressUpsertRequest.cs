using System;

namespace ScoutTrack.Model.Requests
{
    public class MemberBadgeProgressUpsertRequest
    {
        public int MemberBadgeId { get; set; }
        public int RequirementId { get; set; }
        public bool IsCompleted { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}
