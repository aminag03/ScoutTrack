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
        
        // Additional Activity data for better display
        public string ActivityDescription { get; set; } = string.Empty;
        public string ActivityLocationName { get; set; } = string.Empty;
        public string ActivityTypeName { get; set; } = string.Empty;
        public string ActivityState { get; set; } = string.Empty;
        public DateTime? ActivityStartTime { get; set; }
        public DateTime? ActivityEndTime { get; set; }
        public decimal ActivityFee { get; set; }
        public string ActivityImagePath { get; set; } = string.Empty;
        public int TroopId { get; set; }
        public string TroopName { get; set; } = string.Empty;
        public int ActivityTypeId { get; set; }
        public double ActivityLatitude { get; set; }
        public double ActivityLongitude { get; set; }
    }
} 