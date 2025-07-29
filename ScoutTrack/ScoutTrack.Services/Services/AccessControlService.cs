using Microsoft.EntityFrameworkCore;
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
            var role = _authService.GetUserRole(user);

            Console.WriteLine($"Checking access for MemberID: {memberId}, TroopID: {troopId}, Role: {role}");

            if (role != "Troop" || troopId == null)
                return false;

            var exists = await _context.Members.AnyAsync(m => m.Id == memberId);
            Console.WriteLine($"Exists in DB: {exists}");

            var member = await _context.Members
                .IgnoreQueryFilters() // if needed
                .FirstOrDefaultAsync(m => m.Id == memberId);

            Console.WriteLine($"Fetched Member TroopId: {member?.TroopId}");

            return member != null && member.TroopId == troopId;
        }


        public async Task<bool> CanTroopAccessActivityAsync(ClaimsPrincipal user, int activityId)
        {
            if (!_authService.IsInRole(user, "Troop"))
                return false;

            var troopId = _authService.GetUserId(user);
            if (troopId == null) return false;

            var activity = await _context.Activities
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == activityId);

            return activity != null && activity.TroopId == troopId;
        }
    }
}
