using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.Requests
{
    public class ChangePasswordRequest
    {
        public string OldPassword { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
        public string ConfirmNewPassword { get; set; } = null!;
    }
}
