using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using Microsoft.AspNetCore.Authorization;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MemberController : BaseCRUDController<MemberResponse, MemberSearchObject, MemberUpsertRequest, MemberUpsertRequest>
    {
        private readonly IAuthService _authService;
        public MemberController(IMemberService memberService, IAuthService authService) : base(memberService)
        {
            _authService = authService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Create([FromBody] MemberUpsertRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _authService.CanTroopAccessMember(User, request.TroopId))
                {
                    return Forbid();
                }
            }
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] MemberUpsertRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _authService.CanTroopAccessMember(User, request.TroopId))
                {
                    return Forbid();
                }
            }
            if (_authService.IsInRole(User, "Member"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _authService.CanTroopAccessMember(User, member.TroopId))
                {
                    return Forbid();
                }
            }
            if (_authService.IsInRole(User, "Member"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }
    }
} 