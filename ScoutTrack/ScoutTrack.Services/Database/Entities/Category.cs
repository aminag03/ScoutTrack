using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Services.Database.Entities
{
    public class Category
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public int MinAge { get; set; }

        [Required]
        public int MaxAge { get; set; }

        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<Member> Members { get; set; } = new List<Member>();
    }
}
