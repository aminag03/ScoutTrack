using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;

namespace ScoutTrack.Model.SearchObjects
{
    public class ActivitySearchObject : BaseSearchObject
    {
        public string Title { get; set; } = string.Empty;
        public int? TroopId { get; set; }
        public int? ActivityTypeId { get; set; }
        public bool? IsPrivate { get; set; }
        public bool? ShowPublicAndOwn { get; set; }
        public int? OwnTroopId { get; set; }
        public string? ActivityState { get; set; }
        public List<string>? ExcludeStates { get; set; }
    }
} 