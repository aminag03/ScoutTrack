using System;

namespace ScoutTrack.Model.Responses
{
    public class BadgeRequirementResponse
    {
        public int Id { get; set; }
        public int BadgeId { get; set; }
        public string BadgeName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
