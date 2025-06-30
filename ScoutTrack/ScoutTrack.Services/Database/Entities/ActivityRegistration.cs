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
    public class ActivityRegistration
    {
        [Key]
        public int Id { get; set; }
        public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(Activity))]
        public int ActivityId { get; set; }
        public Activity Activity { get; set; } = null!;

        [ForeignKey(nameof(Member))]
        public int MemberId { get; set; }
        public Member Member { get; set; } = null!;

        public RegistrationStatus Status { get; set; } = RegistrationStatus.Pending;
        public string Notes { get; set; } = string.Empty;
    }
}
