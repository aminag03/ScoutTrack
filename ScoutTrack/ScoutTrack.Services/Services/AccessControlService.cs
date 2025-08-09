using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Interfaces;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class AccessControlService : IAccessControlService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly IAuthService _authService;

        public AccessControlService(ScoutTrackDbContext context, IAuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        public async Task<bool> CanTroopAccessMemberAsync(ClaimsPrincipal user, int memberId)
        {
            var troopId = _authService.GetUserId(user);

            if (!_authService.IsInRole(user, "Troop") || troopId == null)
                return false;

            var member = await _context.Members
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(m => m.Id == memberId);

            return member != null && member.TroopId == troopId;
        }


        public async Task<bool> CanTroopAccessActivityAsync(ClaimsPrincipal user, int activityId)
        {
            if (!_authService.IsInRole(user, "Troop"))
                return false;

            var troopId = _authService.GetUserId(user);
            if (troopId == null) return false;


            var activity = await _context.Activities
                .FirstOrDefaultAsync(a => a.Id == activityId);

            return activity != null && activity.TroopId == troopId;
        }

        public async Task<bool> CanViewActivityRegistrationAsync(ClaimsPrincipal user, int registrationId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            var registration = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .FirstOrDefaultAsync(ar => ar.Id == registrationId);

            if (registration == null) return false;

            if (userRole == "Troop")
            {
                return registration.Activity.TroopId == userId;
            }

            if (userRole == "Member")
            {
                return registration.MemberId == userId;
            }

            return false;
        }

        public async Task<bool> CanModifyActivityRegistrationAsync(ClaimsPrincipal user, int registrationId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            var registration = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .FirstOrDefaultAsync(ar => ar.Id == registrationId);

            if (registration == null) return false;

            if (userRole == "Member")
            {
                return registration.MemberId == userId;
            }

            return false;
        }

        public async Task<bool> CanApproveActivityRegistrationAsync(ClaimsPrincipal user, int registrationId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Troop")
            {
                var registration = await _context.ActivityRegistrations
                    .Include(ar => ar.Activity)
                    .FirstOrDefaultAsync(ar => ar.Id == registrationId);

                if (registration == null) return false;

                return registration.Activity.TroopId == userId;
            }

            return false;
        }

        public async Task<bool> CanCancelActivityRegistrationAsync(ClaimsPrincipal user, int registrationId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Member")
            {
                var registration = await _context.ActivityRegistrations
                    .Include(ar => ar.Activity)
                    .FirstOrDefaultAsync(ar => ar.Id == registrationId);

                if (registration == null) return false;

                if (registration.MemberId != userId) return false;

                if (registration.Activity.ActivityState != "ActiveActivityState")
                {
                    return false;
                }

                return true;
            }

            return false;
        }

        public async Task<bool> CanCompleteActivityRegistrationAsync(ClaimsPrincipal user, int registrationId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Troop")
            {
                var registration = await _context.ActivityRegistrations
                    .Include(ar => ar.Activity)
                    .FirstOrDefaultAsync(ar => ar.Id == registrationId);

                if (registration == null) return false;

                return registration.Activity.TroopId == userId;
            }

            return false;
        }

        public async Task<bool> CanViewActivityAsync(ClaimsPrincipal user, int activityId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            var activity = await _context.Activities
                .FirstOrDefaultAsync(a => a.Id == activityId);

            if (activity == null) return false;

            if (activity.isPrivate)
            {
                if (userRole == "Troop")
                {
                    return activity.TroopId == userId;
                }
                else if (userRole == "Member")
                {
                    var member = await _context.Members
                        .FirstOrDefaultAsync(m => m.Id == userId);
                    
                    return member != null && member.TroopId == activity.TroopId;
                }
                return false;
            }

            return true;
        }

        public async Task<bool> CanRegisterForActivityAsync(ClaimsPrincipal user, int activityId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Member")
            {
                var activity = await _context.Activities
                    .FirstOrDefaultAsync(a => a.Id == activityId);

                if (activity == null) return false;

                if (activity.ActivityState != "ActiveActivityState")
                {
                    return false;
                }

                if (activity.isPrivate)
                {
                    var member = await _context.Members
                        .FirstOrDefaultAsync(m => m.Id == userId);
                    
                    return member != null && member.TroopId == activity.TroopId;
                }

                var memberExists = await _context.Members
                    .AnyAsync(m => m.Id == userId);
                
                return memberExists;
            }

            return false;
        }

        public async Task<bool> CanReviewActivityAsync(ClaimsPrincipal user, int activityId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole != "Member" || userId == null)
                return false;

            // Check if activity is finished
            var activity = await _context.Activities
                .FirstOrDefaultAsync(a => a.Id == activityId);

            if (activity == null || activity.ActivityState != "FinishedActivityState")
                return false;

            // Check if member has a completed registration for this activity
            var registration = await _context.ActivityRegistrations
                .FirstOrDefaultAsync(ar => ar.ActivityId == activityId && ar.MemberId == userId);

            return registration != null && registration.Status == Common.Enums.RegistrationStatus.Completed;
        }

        public async Task<bool> CanModifyReviewAsync(ClaimsPrincipal user, int reviewId)
        {
            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Member" && userId != null)
            {
                var review = await _context.Reviews
                    .FirstOrDefaultAsync(r => r.Id == reviewId);

                return review != null && review.MemberId == userId;
            }

            return false;
        }

        public async Task<bool> CanCreatePostAsync(ClaimsPrincipal user, int activityId)
        {
            var activity = await _context.Activities
                .Include(a => a.Registrations)
                .FirstOrDefaultAsync(a => a.Id == activityId);

            if (activity == null) return false;

            if (activity.ActivityState != "FinishedActivityState") return false;

            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return false;

            if (userRole == "Troop" && activity.TroopId == userId) return true;

            if (userRole == "Member")
            {
                var registration = activity.Registrations
                    .FirstOrDefault(r => r.MemberId == userId && r.Status == Common.Enums.RegistrationStatus.Completed);
                return registration != null;
            }

            return false;
        }

        public async Task<bool> CanEditPostAsync(ClaimsPrincipal user, int postId)
        {
            var post = await _context.Posts
                .Include(p => p.Activity)
                .FirstOrDefaultAsync(p => p.Id == postId);

            if (post == null) return false;

            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return false;

            if (post.CreatedById == userId) return true;

            return false;
        }

        public async Task<bool> CanDeletePostAsync(ClaimsPrincipal user, int postId)
        {
            var post = await _context.Posts
                .Include(p => p.Activity)
                .FirstOrDefaultAsync(p => p.Id == postId);

            if (post == null) return false;

            var userId = _authService.GetUserId(user);
            var userRole = _authService.GetUserRole(user);

            if (userRole == "Admin") return true;

            if (userRole == "Troop" && post.Activity.TroopId == userId) return true;

            if (post.CreatedById == userId) return true;

            return false;
        }
    }
}
