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
    public class MemberBadge
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Member))]
        public int MemberId { get; set; }
        public Member Member { get; set; } = null!;

        [ForeignKey(nameof(Badge))]
        public int BadgeId { get; set; }
        public Badge Badge { get; set; } = null!;

        public BadgeStatus Status { get; set; }
        public DateTime? CompletedAt { get; set; }
    }
}
