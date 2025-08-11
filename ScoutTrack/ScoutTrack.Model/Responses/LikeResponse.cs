using System;

namespace ScoutTrack.Model.Responses
{
    public class LikeResponse
    {
        public int Id { get; set; }
        public DateTime LikedAt { get; set; }
        public int PostId { get; set; }
        public int CreatedById { get; set; }
        public string CreatedByName { get; set; } = string.Empty;
        public string? CreatedByTroopName { get; set; }
        public string? CreatedByAvatarUrl { get; set; }
        public bool CanUnlike { get; set; } = false;
    }
}
