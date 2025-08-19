using System;

namespace ScoutTrack.Model.Responses
{
    public class DocumentResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int AdminId { get; set; }
        public string AdminFullName { get; set; } = string.Empty;
    }
}
