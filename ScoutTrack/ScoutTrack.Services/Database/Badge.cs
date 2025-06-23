using System;

namespace ScoutTrack.Services.Database
{
    public class Badge
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;    
        public string ImageUrl { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
