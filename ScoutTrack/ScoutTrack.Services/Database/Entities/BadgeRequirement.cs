using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class BadgeRequirement
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Badge))]
        public int BadgeId { get; set; }
        public Badge Badge { get; set; } = null!;

        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
