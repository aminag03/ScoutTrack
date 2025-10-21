using System;
using System.Collections.Generic;

namespace ScoutTrack.Model.Events
{
    public class NotificationEvent
    {
        public string Message { get; set; }
        public List<int> UserIds { get; set; }
        public int SenderId { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? ActivityId { get; set; }
        public string? NotificationType { get; set; }
    }
}

