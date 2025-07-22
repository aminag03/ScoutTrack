using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class AdminUpdateRequest
    {
        [Required]
        [MaxLength(50, ErrorMessage = "Username must not exceed 50 characters.")]
        [RegularExpression(@"^[a-zA-Z0-9_.-]+$", ErrorMessage = "Username can only contain letters, numbers, dots, underscores, or hyphens.")]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "Email must not exceed 100 characters.")]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "FullName must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-z���掞����\s'-]{2,}$", ErrorMessage = "Full name contains invalid characters.")]
        public string FullName { get; set; } = string.Empty;
    }
}