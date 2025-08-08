using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int Rating { get; set; }
        public int ActivityId { get; set; }
        public int MemberId { get; set; }
        public string ActivityTitle { get; set; } = string.Empty;
        public string MemberName { get; set; } = string.Empty;
    }
}
