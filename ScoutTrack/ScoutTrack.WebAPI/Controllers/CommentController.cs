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
    public class CommentController : BaseCRUDController<CommentResponse, CommentSearchObject, CommentUpsertRequest, CommentUpsertRequest>
    {
        private readonly ICommentService _commentService;
        private readonly IAccessControlService _accessControlService;

        public CommentController(ICommentService commentService, IAccessControlService accessControlService) 
            : base(commentService)
        {
            _commentService = commentService;
            _accessControlService = accessControlService;
        }

        [HttpGet("post/{postId}")]
        public async Task<PagedResult<CommentResponse>> GetByPost(int postId, [FromQuery] CommentSearchObject? search)
        {
            search ??= new CommentSearchObject();
            return await _commentService.GetByPostAsync(postId, search);
        }

        [HttpPost]
        [Authorize(Roles = "Troop,Member")]
        public override async Task<IActionResult> Create([FromBody] CommentUpsertRequest request)
        {
            if (!await _accessControlService.CanCreateCommentAsync(User, request.PostId))
            {
                throw new UnauthorizedAccessException("You are not authorized to create comments for this post.");
            }

            try
            {
                var userId = int.Parse(User.FindFirst("UserId")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                
                var result = await _commentService.CreateForUserAsync(request, User);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Troop,Member")]
        public override async Task<IActionResult> Update(int id, [FromBody] CommentUpsertRequest request)
        {
            if (!await _accessControlService.CanEditCommentAsync(User, id))
            {
                return Forbid("You are not authorized to edit this comment.");
            }

            try
            {
                var result = await _commentService.UpdateAsync(id, request);
                if (result == null)
                    return NotFound();
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public override async Task<IActionResult> Delete(int id)
        {
            if (!await _accessControlService.CanDeleteCommentAsync(User, id))
            {
                return Forbid("You are not authorized to delete this comment.");
            }

            try
            {
                var result = await _commentService.DeleteAsync(id);
                if (!result)
                    return NotFound();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
