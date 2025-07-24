using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class AdminInsertRequest
    {
        [Required]
        [MaxLength(50, ErrorMessage = "Username must not exceed 50 characters.")]
        [RegularExpression(@"^[A-Za-z0-9_.]+$", ErrorMessage = "Username can only contain letters, numbers, dots, underscores, or hyphens.")]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "Email must not exceed 100 characters.")]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters long.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$",
        ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.")]
        public string Password { get; set; } = string.Empty;

        [Required]
        [MaxLength(100, ErrorMessage = "FullName must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "Full name contains invalid characters.")]
        public string FullName { get; set; } = string.Empty;
    }
} 