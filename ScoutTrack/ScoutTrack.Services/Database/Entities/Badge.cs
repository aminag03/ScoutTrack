using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Services.Database.Entities
{
    public class Badge
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;   
        
        public string ImageUrl { get; set; } = string.Empty;

        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public ICollection<BadgeRequirement> Requirements { get; set; } = new List<BadgeRequirement>();
        public ICollection<MemberBadge> MemberBadges { get; set; } = new List<MemberBadge>();

    }
}
