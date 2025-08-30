using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Notification
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(500)]
        public string Message { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey(nameof(Receiver))]
        public int ReceiverId { get; set; }
        public UserAccount Receiver { get; set; } = null!;

        [ForeignKey(nameof(Sender))]
        public int? SenderId { get; set; }
        public UserAccount? Sender { get; set; }

        public bool IsRead { get; set; } = false;
    }
}
