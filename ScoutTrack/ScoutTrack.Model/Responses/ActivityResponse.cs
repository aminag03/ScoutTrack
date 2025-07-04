using System;

namespace ScoutTrack.Model.Responses
{
    public class ActivityResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public decimal? Fee { get; set; }
        public int TroopId { get; set; }
        public int ActivityTypeId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string ActivityState { get; set; } = string.Empty;
    }
} 