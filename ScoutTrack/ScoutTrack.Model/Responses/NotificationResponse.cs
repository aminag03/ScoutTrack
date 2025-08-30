using System;

namespace ScoutTrack.Model.Responses
{
    public class NotificationResponse
    {
        public int Id { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public int ReceiverId { get; set; }
        public string ReceiverUsername { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public string SenderUsername { get; set; } = string.Empty;
        public int? SenderId { get; set; }
    }
}
