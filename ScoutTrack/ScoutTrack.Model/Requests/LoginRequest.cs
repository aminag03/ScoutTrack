using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class LoginRequest
    {
        [Required]
        [MinLength(2)]
        public string UsernameOrEmail { get; set; } = string.Empty;
        [Required]
        [MinLength(8)]
        public string Password { get; set; } = string.Empty;
    }
}
