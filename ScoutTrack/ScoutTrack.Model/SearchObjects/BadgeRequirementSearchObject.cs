using System;

namespace ScoutTrack.Model.SearchObjects
{
    public class BadgeRequirementSearchObject : BaseSearchObject
    {
        public int? BadgeId { get; set; }
        public string Description { get; set; } = string.Empty;
    }
}
