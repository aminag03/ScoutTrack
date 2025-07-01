using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class RefreshTokenRequest
    {
        [Required]
        public string RefreshToken { get; set; }
    }
} 