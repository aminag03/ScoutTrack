using System;
using System.ComponentModel.DataAnnotations;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Requests
{
    public class MemberUpdateRequest
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
    }
}