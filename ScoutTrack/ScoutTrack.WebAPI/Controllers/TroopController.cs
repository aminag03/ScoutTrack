using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using Microsoft.AspNetCore.Authorization;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TroopController : BaseCRUDController<TroopResponse, TroopSearchObject, TroopInsertRequest, TroopUpdateRequest>
    {
        private readonly IAuthService _authService;
        private readonly ITroopService _troopService;
        public TroopController(ITroopService troopService, IAuthService authService) : base(troopService)
        {
            _authService = authService;
            _troopService = troopService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Create([FromBody] TroopInsertRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Update(int id, [FromBody] TroopUpdateRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != id)
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
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Delete(id);
        }

        [HttpPatch("{id}/de-activate")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> DeActivate(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }

            var result = await _troopService.DeActivateAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPatch("{id}/change-password")]
        [Authorize(Roles = "Troop")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            if (_authService.GetUserId(User) != id)
            {
                return Forbid();
            }

            var result = await _troopService.ChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPatch("{id}/admin-change-password")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AdminChangePassword(int id, [FromBody] AdminChangePasswordRequest request)
        {
            var result = await _troopService.AdminChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPost("{id}/update-logo")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> UpdateLogo(int id, [FromForm] ImageUploadRequest? request, [FromServices] IWebHostEnvironment env)
        {
            if (_authService.IsInRole(User, "Troop") && _authService.GetUserId(User) != id)
                return Forbid();

            if (request == null || request.Image == null || request.Image.Length == 0)
            {
                var updated = await _troopService.UpdateLogoAsync(id, null);
                return Ok(updated);
            }

            var extension = Path.GetExtension(request.Image.FileName);
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };

            if (!allowedExtensions.Contains(extension.ToLower()))
                return BadRequest("Unsupported file type.");

            var folder = Path.Combine(env.WebRootPath, "images", "troops");
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await request.Image.CopyToAsync(stream);
            }

            var imageUrl = $"{Request.Scheme}://{Request.Host}/images/troops/{fileName}";

            var updatedResponse = await _troopService.UpdateLogoAsync(id, imageUrl);

            return Ok(updatedResponse);
        }

        [HttpGet("{id}/dashboard")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> GetDashboard(int id, [FromQuery] int? year = null, [FromQuery] int? timePeriodDays = null)
        {
            if (_authService.IsInRole(User, "Troop") && _authService.GetUserId(User) != id)
                return Forbid();

            var dashboard = await _troopService.GetDashboardAsync(id, year, timePeriodDays);
            if (dashboard == null)
                return NotFound();

            return Ok(dashboard);
        }
    }
} 