using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Like
    {
        [Key]
        public int Id { get; set; }
        public DateTime LikedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(Post))]
        public int PostId { get; set; }
        public Post Post { get; set; } = null!;

        [ForeignKey(nameof(CreatedBy))]
        public int CreatedById { get; set; }
        public UserAccount CreatedBy { get; set; } = null!;
    }
}
