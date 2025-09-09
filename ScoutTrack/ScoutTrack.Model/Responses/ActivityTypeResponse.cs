using System;

namespace ScoutTrack.Model.Responses
{
    public class ActivityTypeResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int ActivityCount { get; set; }
    }
} 