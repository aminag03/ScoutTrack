using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.Requests
{
    public class LoginRequest
    {
        public string UsernameOrEmail { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}
