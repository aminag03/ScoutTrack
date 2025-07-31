using System;

namespace ScoutTrack.Model.Responses
{
    public class ActivityResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool isPrivate { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public int? CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public decimal? Fee { get; set; }
        public int TroopId { get; set; }
        public string TroopName { get; set; } = string.Empty;
        public int ActivityTypeId { get; set; }
        public string ActivityTypeName {  get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string ActivityState { get; set; } = string.Empty;
        public int MemberCount { get; set; } = 0;
        public string? ImagePath { get; set; }
    }
} 