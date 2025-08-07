using ScoutTrack.Common.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.Requests
{
    public class ActivityRegistrationUpsertRequest
    {
        [Required]
        public int ActivityId { get; set; }

        [MaxLength(1000)]
        public string Notes { get; set; } = string.Empty;
    }
} 