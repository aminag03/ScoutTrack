using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BadgeController : BaseCRUDController<BadgeResponse, BadgeSearchObject, BadgeUpsertRequest, BadgeUpsertRequest>
    {
        public BadgeController(IBadgeService badgeService) : base(badgeService)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Create([FromBody] BadgeUpsertRequest request)
        {
            return base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Update(int id, [FromBody] BadgeUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
