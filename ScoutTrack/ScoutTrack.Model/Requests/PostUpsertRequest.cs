using System;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace ScoutTrack.Model.Requests
{
    public class PostUpsertRequest
    {
        [MaxLength(1000, ErrorMessage = "Content must not exceed 1000 characters.")]
        public string Content { get; set; } = string.Empty;

        [Required]
        public int ActivityId { get; set; }

        public List<string> ImageUrls { get; set; } = new List<string>();
    }
}
