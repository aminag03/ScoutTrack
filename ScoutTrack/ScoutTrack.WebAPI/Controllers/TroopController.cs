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
    public class TroopController : BaseCRUDController<TroopResponse, TroopSearchObject, TroopUpsertRequest, TroopUpsertRequest>
    {
        public TroopController(ITroopService troopService) : base(troopService)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Create([FromBody] TroopUpsertRequest request)
        {
            // Only Admin can create, so no need for custom logic
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Update(int id, [FromBody] TroopUpsertRequest request)
        {
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
            if (userRole == "Troop")
            {
                var troopIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (troopIdClaim == null || int.Parse(troopIdClaim) != id)
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
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
            if (userRole == "Troop")
            {
                var troopIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (troopIdClaim == null || int.Parse(troopIdClaim) != id)
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }
    }
} 