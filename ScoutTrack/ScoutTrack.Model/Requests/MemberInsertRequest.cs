using System;
using System.ComponentModel.DataAnnotations;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Requests
{
    public class MemberInsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        public DateTime BirthDate { get; set; }

        [Required]
        [EnumDataType(typeof(Gender), ErrorMessage = "Invalid gender value.")]
        public Gender Gender { get; set; }

        [Required]
        [Phone]
        [MaxLength(20)]
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
    }
}