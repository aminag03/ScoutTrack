using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Model.SearchObjects
{
    public class CommentSearchObject : BaseSearchObject
    {
        public int? PostId { get; set; }
        public int? CreatedById { get; set; }
        public string? FTS { get; set; }
    }
}
