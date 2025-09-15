using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.SearchObjects
{
    public class MemberSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public int? TroopId { get; set; }
        public int? CityId { get; set; }
        public Gender? Gender { get; set; }
        public int? CategoryId { get; set; }
    }
} 