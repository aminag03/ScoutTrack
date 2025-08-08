using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using System.Security.Claims;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ReviewController : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewUpsertRequest, ReviewUpsertRequest>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService service) : base(service)
        {
            _reviewService = service;
        }

        [HttpGet("by-activity/{activityId}")]
        public async Task<IActionResult> GetByActivity(int activityId, [FromQuery] ReviewSearchObject search)
        {
            var result = await _reviewService.GetByActivityAsync(activityId, search);
            return Ok(result);
        }


        [HttpPost]
        [Authorize(Roles = "Member")]
        public override async Task<IActionResult> Create([FromBody] ReviewUpsertRequest request)
        {
            var result = await _reviewService.CreateForMemberAsync(User, request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Member")]
        public override async Task<IActionResult> Update(int id, [FromBody] ReviewUpsertRequest request)
        {
            var result = await _reviewService.UpdateForMemberAsync(User, id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Member,Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            var result = await _reviewService.DeleteForMemberAsync(User, id);
            if (!result)
                return NotFound();
            return Ok(result);
        }
    }
}
