using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Interfaces;
using System;
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
                    .FirstOrDefaultAsync(ar => ar.Id == registrationId);

                if (registration == null) return false;

                return registration.MemberId == userId;
            }

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
    }
}
