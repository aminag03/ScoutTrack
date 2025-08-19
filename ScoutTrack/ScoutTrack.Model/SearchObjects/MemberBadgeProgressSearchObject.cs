using System;

namespace ScoutTrack.Model.SearchObjects
{
    public class MemberBadgeProgressSearchObject : BaseSearchObject
    {
        public int? MemberBadgeId { get; set; }
        public int? RequirementId { get; set; }
        public bool? IsCompleted { get; set; }
    }
}
