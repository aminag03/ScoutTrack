using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IAccessControlService
    {
        Task<bool> CanTroopAccessMemberAsync(ClaimsPrincipal user, int memberId);
        Task<bool> CanTroopAccessActivityAsync(ClaimsPrincipal user, int activityId);
        Task<bool> CanViewActivityRegistrationAsync(ClaimsPrincipal user, int registrationId);
        Task<bool> CanModifyActivityRegistrationAsync(ClaimsPrincipal user, int registrationId);
        Task<bool> CanApproveActivityRegistrationAsync(ClaimsPrincipal user, int registrationId);
        Task<bool> CanCancelActivityRegistrationAsync(ClaimsPrincipal user, int registrationId);
        Task<bool> CanCompleteActivityRegistrationAsync(ClaimsPrincipal user, int registrationId);
        Task<bool> CanViewActivityAsync(ClaimsPrincipal user, int activityId);
        Task<bool> CanRegisterForActivityAsync(ClaimsPrincipal user, int activityId);
        Task<bool> CanReviewActivityAsync(ClaimsPrincipal user, int activityId);
        Task<bool> CanModifyReviewAsync(ClaimsPrincipal user, int reviewId);
    }
}
