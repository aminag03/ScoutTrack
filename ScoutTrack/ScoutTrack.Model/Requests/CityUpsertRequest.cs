using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class CityUpsertRequest
    {
        [Required]
        [MaxLength(100, ErrorMessage = "Name must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$", ErrorMessage = "City name can only contain letters (A-Ž, a-ž), whitespaces and hyphens (-).")]
        public string Name { get; set; } = string.Empty;

        [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90.")]
        public double Latitude { get; set; }

        [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180.")]
        public double Longitude { get; set; }
    }
} 