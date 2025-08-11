using System;

namespace ScoutTrack.Model.Responses
{
    public class CommentResponse
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int PostId { get; set; }
        public int CreatedById { get; set; }
        public string CreatedByName { get; set; } = string.Empty;
        public string? CreatedByTroopName { get; set; }
        public string? CreatedByAvatarUrl { get; set; }
        public bool CanEdit { get; set; } = false;
        public bool CanDelete { get; set; } = false;
    }
}
