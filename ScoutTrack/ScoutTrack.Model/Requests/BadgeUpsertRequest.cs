using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class BadgeUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        [Required]
        public string ImageUrl { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}
