using System;

namespace ScoutTrack.Model.Responses
{
    public class MemberBadgeProgressResponse
    {
        public int Id { get; set; }
        public int MemberBadgeId { get; set; }
        public int RequirementId { get; set; }
        public string RequirementDescription { get; set; } = string.Empty;
        public bool IsCompleted { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
