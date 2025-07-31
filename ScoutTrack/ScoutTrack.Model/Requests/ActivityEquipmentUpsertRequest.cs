using System;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class ActivityEquipmentUpsertRequest
    {
        [Required]
        public int ActivityId { get; set; }

        [Required]
        public int EquipmentId { get; set; }
    }
} 