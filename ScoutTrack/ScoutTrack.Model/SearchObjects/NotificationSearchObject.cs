using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Model.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public int? ReceiverId { get; set; }
        public bool? IsRead { get; set; }
        public string? Message { get; set; }
    }
}
