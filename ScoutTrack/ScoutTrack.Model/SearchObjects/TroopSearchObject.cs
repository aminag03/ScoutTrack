using ScoutTrack.Model.SearchObjects;
using System;

namespace ScoutTrack.Model.SearchObjects
{
    public class TroopSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public DateTime? FoundingDateFrom { get; set; }
        public DateTime? FoundingDateTo { get; set; }
    }
} 