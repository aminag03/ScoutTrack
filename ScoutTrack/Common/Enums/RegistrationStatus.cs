using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Common.Enums
{
    public enum RegistrationStatus
    {
        Pending,    // Registration is pending approval
        Approved,   // Registration has been approved
        Rejected,   // Registration has been rejected
        Completed   // Registration is completed (e.g., for past activities)
    }
}
