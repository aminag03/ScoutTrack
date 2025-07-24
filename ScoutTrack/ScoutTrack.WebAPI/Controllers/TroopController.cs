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
    public class TroopController : BaseCRUDController<TroopResponse, TroopSearchObject, TroopInsertRequest, TroopUpdateRequest>
    {
        private readonly IAuthService _authService;
        private readonly ITroopService _troopService;
        public TroopController(ITroopService troopService, IAuthService authService) : base(troopService)
        {
            _authService = authService;
            _troopService = troopService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Create([FromBody] TroopInsertRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Update(int id, [FromBody] TroopUpdateRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Delete(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }

        [HttpPatch("{id}/de-activate")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> DeActivate(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }

            var result = await _troopService.DeActivateAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPatch("{id}/change-password")]
        [Authorize(Roles = "Troop")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            if (_authService.GetUserId(User) != id)
            {
                return Forbid();
            }

            var result = await _troopService.ChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
    }
} 