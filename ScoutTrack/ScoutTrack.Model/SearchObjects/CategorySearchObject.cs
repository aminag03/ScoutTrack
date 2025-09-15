using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Model.SearchObjects
{
    public class CategorySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? MinAge { get; set; }
        public int? MaxAge { get; set; }
    }
}
