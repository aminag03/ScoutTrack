using System;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Responses
{
    public class MemberResponse
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public DateTime BirthDate { get; set; }
        public Gender Gender { get; set; }
        public string ContactPhone { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public int TroopId { get; set; }
        public string TroopName { get; set; } = string.Empty;
        public int CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
    }
} 