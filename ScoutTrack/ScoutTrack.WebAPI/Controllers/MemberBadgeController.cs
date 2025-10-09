using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MemberBadgeController : BaseCRUDController<MemberBadgeResponse, MemberBadgeSearchObject, MemberBadgeUpsertRequest, MemberBadgeUpsertRequest>
    {
        private readonly IMemberBadgeService _memberBadgeService;
        private readonly IAuthService _authService;

        public MemberBadgeController(IMemberBadgeService memberBadgeService, IAuthService authService) : base(memberBadgeService)
        {
            _memberBadgeService = memberBadgeService;
            _authService = authService;
        }

        [HttpGet("badge/{badgeId}/status/{status}")]
        [Authorize]
        public async Task<ActionResult<List<MemberBadgeResponse>>> GetMembersByBadgeStatus(int badgeId, MemberBadgeStatus status)
        {
            var result = await _memberBadgeService.GetMembersByBadgeStatusAsync(badgeId, status);
            return Ok(result);
        }

        [HttpGet("badge/{badgeId}/status/{status}/troop/{troopId}")]
        [Authorize]
        public async Task<ActionResult<List<MemberBadgeResponse>>> GetMembersByBadgeStatusAndTroop(int badgeId, MemberBadgeStatus status, int troopId)
        {
            var result = await _memberBadgeService.GetMembersByBadgeStatusAndTroopAsync(badgeId, status, troopId);
            return Ok(result);
        }

        [HttpPost("{id}/complete")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<ActionResult<bool>> CompleteMemberBadge(int id)
        {
            var result = await _memberBadgeService.CompleteMemberBadgeAsync(id);
            return Ok(result);
        }

        [HttpPost("badge/{badgeId}/sync-progress")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> SyncProgressRecordsForBadge(int badgeId)
        {
            await _memberBadgeService.SyncProgressRecordsForBadge(badgeId);
            return Ok(new { message = "Progress records synchronized successfully" });
        }

        [HttpPost("badge/{badgeId}/sync-progress/troop/{troopId}")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<ActionResult> SyncProgressRecordsForBadgeAndTroop(int badgeId, int troopId)
        {
            var userTroopId = _authService.GetUserId(User);
            var isTroop = _authService.IsInRole(User, "Troop");
            if (isTroop && (userTroopId == null || userTroopId.Value != troopId))
            {
                return Forbid("You are not authorized to sync progress for this troop.");
            }

            await _memberBadgeService.SyncProgressRecordsForBadgeAndTroop(badgeId, troopId);
            return Ok(new { message = "Progress records synchronized successfully for troop" });
        }

        [HttpPost]
        public override Task<IActionResult> Create([FromBody] MemberBadgeUpsertRequest request)
        {
            return base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override Task<IActionResult> Update(int id, [FromBody] MemberBadgeUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}