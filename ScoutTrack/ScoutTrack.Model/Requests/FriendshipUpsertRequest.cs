using System.ComponentModel.DataAnnotations;
using ScoutTrack.Common.Enums;

namespace ScoutTrack.Model.Requests
{
    public class FriendshipUpsertRequest
    {
        [Required]
        public int RequesterId { get; set; }

        [Required]
        public int ResponderId { get; set; }

        [Required]
        [EnumDataType(typeof(FriendshipStatus), ErrorMessage = "Invalid friendship status value.")]
        public FriendshipStatus Status { get; set; }
    }
}
