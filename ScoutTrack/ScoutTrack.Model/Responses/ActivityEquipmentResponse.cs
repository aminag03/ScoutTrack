using System;

namespace ScoutTrack.Model.Responses
{
    public class ActivityEquipmentResponse
    {
        public int Id { get; set; }
        public int ActivityId { get; set; }
        public int EquipmentId { get; set; }
        public string EquipmentName { get; set; } = string.Empty;
        public string EquipmentDescription { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
} 