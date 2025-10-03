using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        public int ActivityId { get; set; }

        [MaxLength(500)]
        public string Content { get; set; } = string.Empty;

        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }
    }
}
