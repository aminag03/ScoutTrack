using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class ActivityTypeUpsertRequest
    {
        [Required]
        [MaxLength(100, ErrorMessage = "Name must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-z0-9ÈèÆæŽžÐðŠš\s\-\']+$", ErrorMessage = "Name contains invalid characters.")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "Description must not exceed 500 characters.")]
        public string Description { get; set; } = string.Empty;
    }
} 