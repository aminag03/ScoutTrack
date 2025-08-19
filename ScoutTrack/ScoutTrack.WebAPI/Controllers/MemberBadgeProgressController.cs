using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    public class MemberBadgeProgressController : BaseCRUDController<MemberBadgeProgressResponse, MemberBadgeProgressSearchObject, MemberBadgeProgressUpsertRequest, MemberBadgeProgressUpsertRequest>
    {
        private readonly IMemberBadgeProgressService _memberBadgeProgressService;

        public MemberBadgeProgressController(IMemberBadgeProgressService memberBadgeProgressService) : base(memberBadgeProgressService)
        {
            _memberBadgeProgressService = memberBadgeProgressService;
        }

        [HttpGet("memberBadge/{memberBadgeId}")]
        [Authorize]
        public async Task<ActionResult<List<MemberBadgeProgressResponse>>> GetByMemberBadgeId(int memberBadgeId)
        {
            var result = await _memberBadgeProgressService.GetByMemberBadgeIdAsync(memberBadgeId);
            return Ok(result);
        }

        [HttpPut("{id}/completion")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<ActionResult<bool>> UpdateCompletion(int id, [FromBody] bool isCompleted)
        {
            var result = await _memberBadgeProgressService.UpdateProgressCompletionAsync(id, isCompleted);
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override Task<IActionResult> Create([FromBody] MemberBadgeProgressUpsertRequest request)
        {
            return base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override Task<IActionResult> Update(int id, [FromBody] MemberBadgeProgressUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
