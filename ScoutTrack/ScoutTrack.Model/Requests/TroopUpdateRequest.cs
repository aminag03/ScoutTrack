using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class TroopUpdateRequest
    {
        [Required]
        [MaxLength(50, ErrorMessage = "Username most not exceed 50 characters.")]
        [RegularExpression(@"^[A-Za-z0-9_.]+$", ErrorMessage = "Username can only contain letters, numbers, dots, underscores, or hyphens.")]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "Email must not exceed 100 characters.")]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "Name must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "Name contains invalid characters.")]
        public string Name { get; set; } = string.Empty;

        [Required]
        public int CityId { get; set; }

        [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90.")]
        public double Latitude { get; set; }

        [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180.")]
        public double Longitude { get; set; }

        [Required]
        [Phone]
        [MaxLength(20)]
        public string ContactPhone { get; set; } = string.Empty;

        public string LogoUrl { get; set; } = string.Empty;
    }
}