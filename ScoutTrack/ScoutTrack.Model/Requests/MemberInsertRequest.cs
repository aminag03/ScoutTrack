using System;
using System.ComponentModel.DataAnnotations;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Requests
{
    public class MemberInsertRequest
    {
        [Required]
        [MaxLength(50, ErrorMessage = "Username most not exceed 50 characters.")]
        [RegularExpression(@"^[A-Za-z0-9_.]+$", ErrorMessage = "Username can only contain letters, numbers, dots, underscores, or hyphens.")]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        [RegularExpression(@"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$", ErrorMessage = "FirstName contains invalid characters.")]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        [RegularExpression(@"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$", ErrorMessage = "LastName contains invalid characters.")]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [Range(1900, 2024, ErrorMessage = "Birth date must be between 1900 and current year.")]
        public DateTime BirthDate { get; set; }

        [Required]
        [EnumDataType(typeof(Gender), ErrorMessage = "Invalid gender value.")]
        public Gender Gender { get; set; }

        [Required]
        [MaxLength(20)]
        [RegularExpression(@"^(\+387|0)[6][0-7][0-9][0-9][0-9][0-9][0-9][0-9]$", ErrorMessage = "PhoneNumber must be a valid phone number for Bosnia and Herzegovina.")]
        public string ContactPhone { get; set; } = string.Empty;

        public string ProfilePictureUrl { get; set; } = string.Empty;

        [Required]
        public int TroopId { get; set; }

        [Required]
        public int CityId { get; set; }

        [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be at least 8 characters long.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$",
            ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.")]
        public string? Password { get; set; }

        public string PasswordConfirm { get; set; } = string.Empty;

    }
}