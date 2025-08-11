using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Model.SearchObjects
{
    public class LikeSearchObject : BaseSearchObject
    {
        public int? PostId { get; set; }
        public int? CreatedById { get; set; }
    }
}
