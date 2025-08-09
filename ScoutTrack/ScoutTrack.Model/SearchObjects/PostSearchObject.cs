using System;

namespace ScoutTrack.Model.SearchObjects
{
    public class PostSearchObject : BaseSearchObject
    {
        public int? ActivityId { get; set; }
        public int? CreatedById { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public string? OrderBy { get; set; } = "-CreatedAt";
    }
}
