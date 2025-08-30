using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Comment
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(1000)]
        public string Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey(nameof(Post))]
        public int PostId { get; set; }
        public Post Post { get; set; } = null!;

        [ForeignKey(nameof(CreatedBy))]
        public int CreatedById { get; set; }
        public UserAccount CreatedBy { get; set; } = null!;
    }
}
