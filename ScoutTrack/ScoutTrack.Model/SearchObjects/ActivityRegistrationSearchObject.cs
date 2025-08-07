using ScoutTrack.Common.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.SearchObjects
{
    public class ActivityRegistrationSearchObject : BaseSearchObject
    {
        public int? ActivityId { get; set; }
        public int? MemberId { get; set; }
        public RegistrationStatus? Status { get; set; }
        public List<int>? OwnTroopActivityIds { get; set; }
    }
} 