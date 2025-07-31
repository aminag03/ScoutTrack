using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Model.SearchObjects
{
    public class ActivityEquipmentSearchObject : BaseSearchObject
    {
        public int? ActivityId { get; set; }
        public int? EquipmentId { get; set; }
    }
} 