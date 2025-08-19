using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class DocumentUpsertRequest
    {
        [Required]
        [MaxLength(100, ErrorMessage = "Title must not exceed 100 characters.")]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string FilePath { get; set; } = string.Empty;
    }
}
