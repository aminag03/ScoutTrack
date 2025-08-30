using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace ScoutTrack.Services.Database.Entities
{
    public class RefreshToken
    {
        public int Id { get; set; }
        public string? Token { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey(nameof(UserAccount))]
        public int UserAccountId { get; set; }
        public UserAccount UserAccount { get; set; } = null!;
        public bool IsRevoked { get; set; }
    }
} 