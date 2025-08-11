using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class CommentUpsertRequest
    {
        [Required]
        [MaxLength(1000, ErrorMessage = "Comment content must not exceed 1000 characters.")]
        public string Content { get; set; } = string.Empty;

        [Required]
        public int PostId { get; set; }
    }
}
