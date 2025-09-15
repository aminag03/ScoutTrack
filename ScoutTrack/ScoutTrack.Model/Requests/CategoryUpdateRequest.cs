using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class CategoryUpdateRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Range(0, 100)]
        public int MinAge { get; set; }

        [Required]
        [Range(0, 100)]
        public int MaxAge { get; set; }

        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
    }
}
