using System;
using System.Collections.Generic;

namespace ScoutTrack.Model.Responses
{
    public class PostResponse
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int ActivityId { get; set; }
        public string ActivityTitle { get; set; } = string.Empty;
        public int CreatedById { get; set; }
        public string CreatedByName { get; set; } = string.Empty;
        public string? CreatedByTroopName { get; set; }
        public string? CreatedByAvatarUrl { get; set; }
        public List<PostImageResponse> Images { get; set; } = new List<PostImageResponse>();
        public int LikeCount { get; set; } = 0;
        public int CommentCount { get; set; } = 0;
        public bool IsLikedByCurrentUser { get; set; } = false;
        public List<LikeResponse> Likes { get; set; } = new List<LikeResponse>();
        public List<CommentResponse> Comments { get; set; } = new List<CommentResponse>();
    }

    public class PostImageResponse
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public DateTime UploadedAt { get; set; }
        public bool IsCoverPhoto { get; set; } = false;
    }
}
