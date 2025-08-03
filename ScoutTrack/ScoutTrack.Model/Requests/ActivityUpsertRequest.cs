using System;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class ActivityUpsertRequest
    {
        [Required]
        [MaxLength(100, ErrorMessage = "Title must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "Name contains invalid characters.")]
        public string Title { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "Description must not exceed 500 characters.")]
        public string Description { get; set; } = string.Empty;

        public bool isPrivate { get; set; }

        public DateTime? StartTime { get; set; }
        
        public DateTime? EndTime { get; set; }

        [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90.")]
        public double Latitude { get; set; }

        [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180.")]
        public double Longitude { get; set; }

        [MaxLength(200, ErrorMessage = "Location name must not exceed 200 characters.")]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "LocationName contains invalid characters.")]
        public string LocationName { get; set; } = string.Empty;

        public int? CityId { get; set; }

        public decimal? Fee { get; set; }

        [Required]
        public int TroopId { get; set; }

        [Required]
        public int ActivityTypeId { get; set; }

        public string? ImagePath { get; set; }

        [MaxLength(2000, ErrorMessage = "Summary must not exceed 2000 characters.")]
        public string Summary { get; set; } = string.Empty;
    }
} 