using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class MemberBadgeProgress
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(MemberBadge))]
        public int MemberBadgeId { get; set; }
        public MemberBadge MemberBadge { get; set; } = null!;

        [ForeignKey(nameof(Requirement))]
        public int RequirementId { get; set; }
        public BadgeRequirement Requirement { get; set; } = null!;

        public bool IsCompleted { get; set; } = false;
        public DateTime? CompletedAt { get; set; }

        // POTENTIAL FUTURE FIELDS
        //[ForeignKey(nameof(Member))]
        //public int? ApprovedById { get; set; }
        //public Member? ApprovedBy { get; set; }
    }
}
