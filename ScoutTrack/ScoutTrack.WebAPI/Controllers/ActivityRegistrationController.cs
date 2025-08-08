using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ActivityRegistrationController : BaseCRUDController<ActivityRegistrationResponse, ActivityRegistrationSearchObject, ActivityRegistrationUpsertRequest, ActivityRegistrationUpsertRequest>
    {
        private readonly IActivityRegistrationService _activityRegistrationService;

        public ActivityRegistrationController(IActivityRegistrationService activityRegistrationService) : base(activityRegistrationService)
        {
            _activityRegistrationService = activityRegistrationService;
        }

        [HttpGet]
        public override async Task<PagedResult<ActivityRegistrationResponse>> Get([FromQuery] ActivityRegistrationSearchObject? search = null)
        {
            search ??= new ActivityRegistrationSearchObject();
            return await _activityRegistrationService.GetAsync(search);
        }

        [HttpGet("by-activity/{activityId}")]
        public async Task<ActionResult<PagedResult<ActivityRegistrationResponse>>> GetByActivity(int activityId, [FromQuery] ActivityRegistrationSearchObject search)
        {
            search ??= new ActivityRegistrationSearchObject();
            search.ActivityId = activityId;
            var result = await _activityRegistrationService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("by-user/{userId}")]
        public async Task<ActionResult<PagedResult<ActivityRegistrationResponse>>> GetByUser(int userId, [FromQuery] ActivityRegistrationSearchObject search)
        {
            search ??= new ActivityRegistrationSearchObject();
            search.MemberId = userId;
            var result = await _activityRegistrationService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public override async Task<ActivityRegistrationResponse?> GetById(int id)
        {
            return await _activityRegistrationService.GetByIdAsync(id);
        }

        [HttpPost]
        [Authorize(Roles = "Member")]
        public override async Task<IActionResult> Create([FromBody] ActivityRegistrationUpsertRequest request)
        {
            var result = await _activityRegistrationService.CreateForUserAsync(User, request);
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Member")]
        public override async Task<IActionResult> Update(int id, [FromBody] ActivityRegistrationUpsertRequest request)
        {
            var result = await _activityRegistrationService.UpdateAsync(id, request);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            var result = await _activityRegistrationService.DeleteAsync(id);
            if (!result)
                return NotFound();

            return NoContent();
        }

        [HttpPost("{id}/approve")]
        [Authorize(Roles = "Troop,Admin")]
        public async Task<ActionResult<ActivityRegistrationResponse>> Approve(int id)
        {
            var result = await _activityRegistrationService.ApproveAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/reject")]
        [Authorize(Roles = "Troop,Admin")]
        public async Task<ActionResult<ActivityRegistrationResponse>> Reject(int id)
        {
            var result = await _activityRegistrationService.RejectAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/cancel")]
        public async Task<ActionResult<ActivityRegistrationResponse>> Cancel(int id)
        {
            var result = await _activityRegistrationService.CancelAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/complete")]
        [Authorize(Roles = "Troop,Admin")]
        public async Task<ActionResult<ActivityRegistrationResponse>> Complete(int id)
        {
            var result = await _activityRegistrationService.CompleteAsync(id);
            return Ok(result);
        }
    }
} 