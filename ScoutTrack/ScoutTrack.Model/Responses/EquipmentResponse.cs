using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.Responses
{
    public class EquipmentResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsGlobal { get; set; } = true;
        public int? CreatedByTroopId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
