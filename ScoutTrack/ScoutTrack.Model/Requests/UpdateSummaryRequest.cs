using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class UpdateSummaryRequest
    {
        [Required(ErrorMessage = "Summary is required.")]
        [MaxLength(2000, ErrorMessage = "Summary must not exceed 2000 characters.")]
        public string Summary { get; set; } = string.Empty;
    }
} 