using ScoutTrack.Common.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.Responses
{
    public class ActivityRegistrationResponse
    {
        public int Id { get; set; }
        public DateTime RegisteredAt { get; set; }
        public int ActivityId { get; set; }
        public int MemberId { get; set; }
        public RegistrationStatus Status { get; set; }
        public string Notes { get; set; } = string.Empty;
        public string ActivityTitle { get; set; } = string.Empty;
        public string MemberName { get; set; } = string.Empty;
    }
} 