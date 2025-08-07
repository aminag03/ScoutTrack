using System;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class TroopInsertRequest
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
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters long.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$",
        ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.")]
        public string Password { get; set; } = string.Empty;

        public string PasswordConfirm { get; set; } = string.Empty;

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
        [MaxLength(100)]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "Name contains invalid characters.")]
        public string ScoutMaster { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [RegularExpression(@"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$", ErrorMessage = "Name contains invalid characters.")]
        public string TroopLeader { get; set; } = string.Empty;

        [Required]
        public DateTime FoundingDate { get; set; }

        [Required]
        [MaxLength(20)]
        [RegularExpression(@"^(\+387|0)[6][0-7][0-9][0-9][0-9][0-9][0-9][0-9]$", 
            ErrorMessage = "PhoneNumber must be a valid phone number for Bosnia and Herzegovina.")]
        public string ContactPhone { get; set; } = string.Empty;

        public string LogoUrl { get; set; } = string.Empty;
    }
} 