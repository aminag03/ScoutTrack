using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using System.Security.Claims;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class LikeController : BaseController<LikeResponse, LikeSearchObject>
    {
        private readonly ILikeService _likeService;
        private readonly IAccessControlService _accessControlService;

        public LikeController(ILikeService likeService, IAccessControlService accessControlService) 
            : base(likeService)
        {
            _likeService = likeService;
            _accessControlService = accessControlService;
        }

        [HttpGet("post/{postId}")]
        public async Task<PagedResult<LikeResponse>> GetByPost(int postId, [FromQuery] LikeSearchObject? search)
        {
            search ??= new LikeSearchObject();
            return await _likeService.GetByPostAsync(postId, search);
        }

        [HttpPost("post/{postId}")]
        [Authorize(Roles = "Troop,Member")]
        public async Task<IActionResult> LikePost(int postId)
        {
            if (!await _accessControlService.CanLikePostAsync(User, postId))
            {
                throw new UnauthorizedAccessException("You are not authorized to like this post.");
            }

            try
            {
                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                var result = await _likeService.LikePostAsync(postId, userId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("post/{postId}")]
        [Authorize(Roles = "Troop,Member")]
        public async Task<IActionResult> UnlikePost(int postId)
        {
            if (!await _accessControlService.CanUnlikePostAsync(User, postId))
            {
                return Forbid("You are not authorized to unlike this post.");
            }

            try
            {
                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                var result = await _likeService.UnlikePostAsync(postId, userId);
                if (result)
                {
                    return NoContent();
                }
                return NotFound();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
