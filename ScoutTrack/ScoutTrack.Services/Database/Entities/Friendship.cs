using ScoutTrack.Common.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Friendship
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Requester))]
        public int RequesterId { get; set; }
        public Member Requester { get; set; } = null!;

        [ForeignKey(nameof(Responder))]
        public int ResponderId { get; set; }
        public Member Responder { get; set; } = null!;

        public DateTime RequestedAt { get; set; } = DateTime.Now;
        public DateTime? RespondedAt { get; set; }
        public FriendshipStatus Status { get; set; }
    }
}
