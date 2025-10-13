using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Interfaces;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class RecommendationController : ControllerBase
    {
        private readonly IActivityService _activityService;
        private readonly IAuthService _authService;

        public RecommendationController(IActivityService activityService, IAuthService authService)
        {
            _activityService = activityService;
            _authService = authService;
        }

        [HttpGet("me")]
        [Authorize(Roles = "Member")]
        public async Task<ActionResult<List<ActivityResponse>>> GetRecommendationsForMe([FromQuery] int topN = 10)
        {
            var memberId = _authService.GetUserId(User);
            
            if (memberId == null)
            {
                return Unauthorized();
            }

            if (topN > 50) topN = 50;
            if (topN < 1) topN = 10;

            var recommendations = await _activityService.GetRecommendedActivitiesForMemberAsync(memberId.Value, topN);
            
            return Ok(recommendations);
        }

        [HttpGet("member/{memberId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<List<ActivityResponse>>> GetRecommendationsForMember(int memberId, [FromQuery] int topN = 10)
        {
            if (topN > 50) topN = 50;
            if (topN < 1) topN = 10;

            var recommendations = await _activityService.GetRecommendedActivitiesForMemberAsync(memberId, topN);
            
            return Ok(recommendations);
        }
    }
}

