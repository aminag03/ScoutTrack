using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services;
using Microsoft.AspNetCore.Hosting;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PostController : BaseCRUDController<PostResponse, PostSearchObject, PostUpsertRequest, PostUpsertRequest>
    {
        private readonly IPostService _postService;
        private readonly IAuthService _authService;
        private readonly IAccessControlService _accessControlService;

        public PostController(IPostService postService, IAuthService authService, IAccessControlService accessControlService) : base(postService)
        {
            _postService = postService;
            _authService = authService;
            _accessControlService = accessControlService;
        }

        [HttpGet]
        public override async Task<PagedResult<PostResponse>> Get([FromQuery] PostSearchObject? search)
        {
            search ??= new PostSearchObject();
            return await _postService.GetAsync(search);
        }

        [HttpGet("{id}")]
        public override async Task<PostResponse?> GetById(int id)
        {
            return await _postService.GetByIdForUserAsync(User, id);
        }

        [HttpGet("activity/{activityId}")]
        public async Task<PagedResult<PostResponse>> GetByActivity(int activityId, [FromQuery] PostSearchObject? search)
        {
            search ??= new PostSearchObject();
            return await _postService.GetByActivityForUserAsync(activityId, search, User);
        }

        [HttpPost]
        public override async Task<IActionResult> Create([FromBody] PostUpsertRequest request)
        {
            if (!await _accessControlService.CanCreatePostAsync(User, request.ActivityId))
            {
                return Forbid("You are not authorized to create posts for this activity.");
            }

            try
            {
                var result = await _postService.CreateAsync(request, User);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public override async Task<IActionResult> Update(int id, [FromBody] PostUpsertRequest request)
        {
            var existingPost = await _postService.GetByIdAsync(id);
            if (existingPost == null)
                return NotFound();

            if (!await _accessControlService.CanEditPostAsync(User, id))
            {
                return Forbid("You are not authorized to edit this post.");
            }

            try
            {
                var result = await _postService.UpdateAsync(id, request);
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
            var existingPost = await _postService.GetByIdAsync(id);
            if (existingPost == null)
                return NotFound();

            if (!await _accessControlService.CanDeletePostAsync(User, id))
            {
                return Forbid("You are not authorized to delete this post.");
            }

            try
            {
                await _postService.DeleteAsync(id);
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/like")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public async Task<IActionResult> LikePost(int id)
        {
            var userId = _authService.GetUserId(User);
            if (userId == null)
                return Unauthorized("User not found");

            try
            {
                var result = await _postService.LikePostAsync(id, userId.Value);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}/like")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public async Task<IActionResult> UnlikePost(int id)
        {
            var userId = _authService.GetUserId(User);
            if (userId == null)
                return Unauthorized("User ID not found");

            try
            {
                var result = await _postService.UnlikePostAsync(id, userId.Value);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }



        [HttpPost("upload-image")]
        [Authorize(Roles = "Admin,Troop,Member")]
        public async Task<IActionResult> UploadImage([FromForm] ImageUploadRequest request, [FromServices] IWebHostEnvironment env)
        {
            if (request?.Image == null || request.Image.Length == 0)
                return BadRequest("No image provided.");

            var extension = Path.GetExtension(request.Image.FileName);
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };

            if (!allowedExtensions.Contains(extension.ToLower()))
                return BadRequest("Unsupported file type.");

            var folder = Path.Combine(env.WebRootPath, "images", "posts");
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await request.Image.CopyToAsync(stream);
            }

            var imagePath = $"images/posts/{fileName}";

            return Ok(new { imageUrl = imagePath });
        }
    }
}
