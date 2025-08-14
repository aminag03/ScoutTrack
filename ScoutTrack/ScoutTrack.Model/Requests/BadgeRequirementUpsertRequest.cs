using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class BadgeRequirementUpsertRequest
    {
        [Required]
        public int BadgeId { get; set; }

        [Required]
        [MaxLength(500, ErrorMessage = "Description must not exceed 500 characters.")]
        public string Description { get; set; } = string.Empty;
    }
}
