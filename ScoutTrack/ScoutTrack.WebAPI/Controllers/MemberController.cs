using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin,Troop,Member")]
    public class MemberController : BaseCRUDController<MemberResponse, MemberSearchObject, MemberUpsertRequest, MemberUpsertRequest>
    {
        public MemberController(IMemberService memberService) : base(memberService)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Create([FromBody] MemberUpsertRequest request)
        {
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
            if (userRole == "Troop")
            {
                var troopIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (troopIdClaim == null || int.Parse(troopIdClaim) != request.TroopId)
                {
                    return Forbid();
                }
            }
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public override async Task<IActionResult> Update(int id, [FromBody] MemberUpsertRequest request)
        {
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userRole == "Troop")
            {
                var troopIdClaim = userIdClaim;
                if (troopIdClaim == null || int.Parse(troopIdClaim) != request.TroopId)
                {
                    return Forbid();
                }
            }
            if (userRole == "Member")
            {
                if (userIdClaim == null || int.Parse(userIdClaim) != id)
                {
                    return Forbid();
                }
            }
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public override async Task<IActionResult> Delete(int id)
        {
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userRole == "Troop")
            {
                var member = await _service.GetByIdAsync(id);
                var troopIdClaim = userIdClaim;
                if (troopIdClaim == null || member == null || int.Parse(troopIdClaim) != member.TroopId)
                {
                    return Forbid();
                }
            }
            if (userRole == "Member")
            {
                if (userIdClaim == null || int.Parse(userIdClaim) != id)
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }
    }
} 