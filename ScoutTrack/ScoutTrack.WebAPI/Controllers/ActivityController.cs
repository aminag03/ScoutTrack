using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Client;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActivityController : BaseCRUDController<ActivityResponse, ActivitySearchObject, ActivityUpsertRequest, ActivityUpsertRequest>
    {
        private readonly IAuthService _authService;
        private readonly IAccessControlService _accessControlService;
        IActivityService _activityService;

        public ActivityController(IActivityService activityService, IAuthService authService, IAccessControlService accessControlService) : base(activityService)
        {
            _authService = authService;
            _accessControlService = accessControlService;
            _activityService = activityService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Create([FromBody] ActivityUpsertRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != request.TroopId)
                {
                    return Forbid();
                }
            }
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Update(int id, [FromBody] ActivityUpsertRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _accessControlService.CanTroopAccessActivityAsync(User, id))
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
                var activity = await _service.GetByIdAsync(id);
                if (activity == null || !await _accessControlService.CanTroopAccessActivityAsync(User, id))
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }

        [HttpPut("{id}/activate")]
        public virtual async Task<ActivityResponse?> ActivateAsync(int id)
        {
            return await _activityService.ActivateAsync(id);
        }

        [HttpPut("{id}/deactivate")]
        public virtual async Task<ActivityResponse?> DeactivateAsync(int id)
        {
            return await _activityService.DeactivateAsync(id);
        }

        [HttpPut("{id}/close-registrations")]
        [Authorize(Roles = "Admin,Troop")]
        public virtual async Task<ActivityResponse?> CloseRegistrationsAsync(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _accessControlService.CanTroopAccessActivityAsync(User, id))
                {
                    return null;
                }
            }
            return await _activityService.CloseRegistrationsAsync(id);
        }

        [HttpPut("{id}/finish")]
        [Authorize(Roles = "Admin,Troop")]
        public virtual async Task<ActivityResponse?> FinishAsync(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _accessControlService.CanTroopAccessActivityAsync(User, id))
                {
                    return null;
                }
            }
            return await _activityService.FinishAsync(id);
        }

        [HttpPost("{id}/update-image")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> UpdateImage(int id, [FromForm] ImageUploadRequest? request, [FromServices] IWebHostEnvironment env)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var activity = await _service.GetByIdAsync(id);
                if (activity == null || !await _accessControlService.CanTroopAccessActivityAsync(User, id))
                {
                    Console.WriteLine("I FORBID YOU TO UPLOAD!!!");
                    return Forbid();
                }
            }

            if (request == null || request.Image == null || request.Image.Length == 0)
            {
                var updated = await _activityService.UpdateImageAsync(id, null);
                return Ok(updated);
            }

            var extension = Path.GetExtension(request.Image.FileName);
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };

            if (!allowedExtensions.Contains(extension.ToLower()))
                return BadRequest("Unsupported file type.");

            var folder = Path.Combine(env.WebRootPath, "images", "activities");
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await request.Image.CopyToAsync(stream);
            }

            var imageUrl = $"{Request.Scheme}://{Request.Host}/images/activities/{fileName}";

            var updatedResponse = await _activityService.UpdateImageAsync(id, imageUrl);

            return Ok(updatedResponse);
        }

        [HttpPut("{id}/update-summary")]
        [Authorize(Roles = "Admin,Troop")]
        public virtual async Task<ActivityResponse?> UpdateSummaryAsync(int id, [FromBody] UpdateSummaryRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (!await _accessControlService.CanTroopAccessActivityAsync(User, id))
                {
                    return null;
                }
            }
            return await _activityService.UpdateSummaryAsync(id, request.Summary);
        }
    }
} 