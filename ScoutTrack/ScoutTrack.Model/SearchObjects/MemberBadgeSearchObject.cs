using System;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.SearchObjects
{
    public class MemberBadgeSearchObject : BaseSearchObject
    {
        public int? MemberId { get; set; }
        public int? BadgeId { get; set; }
        public MemberBadgeStatus? Status { get; set; }
        public string? MemberName { get; set; }
        public string? BadgeName { get; set; }
        public int? TroopId { get; set; }
    }
}
