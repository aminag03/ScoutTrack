using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MemberController : BaseCRUDController<MemberResponse, MemberSearchObject, MemberInsertRequest, MemberUpdateRequest>
    {
        private readonly IAuthService _authService;
        private readonly IAccessControlService _accessControlService;
        private readonly IMemberService _memberService;

        public MemberController(IMemberService memberService, IAuthService authService, IAccessControlService accessControlService) : base(memberService)
        {
            _authService = authService;
            _accessControlService = accessControlService;
            _memberService = memberService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Create([FromBody] MemberInsertRequest request)
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
        public override async Task<IActionResult> Update(int id, [FromBody] MemberUpdateRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _accessControlService.CanTroopAccessMemberAsync(User, member.Id))
                {
                    return Forbid();
                }
            }
            if (_authService.IsInRole(User, "Member"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }
            return await base.Update(id, request);
        }


        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _accessControlService.CanTroopAccessMemberAsync(User, member.Id))
                {
                    return Forbid();
                }
            }
            if (_authService.IsInRole(User, "Member"))
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
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _accessControlService.CanTroopAccessMemberAsync(User, member.Id))
                {
                    return Forbid();
                }
            }

            var result = await _memberService.DeActivateAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPatch("{id}/change-password")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            if (_authService.GetUserId(User) != id)
            {
                return Forbid();
            }

            var result = await _memberService.ChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPatch("{id}/admin-change-password")]
        [Authorize(Roles = "Admin,Troop")]
        public async Task<IActionResult> AdminChangePassword(int id, [FromBody] AdminChangePasswordRequest request)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _accessControlService.CanTroopAccessMemberAsync(User, member.Id))
                {
                    return Forbid();
                }
            }
            var result = await _memberService.AdminChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPost("{id}/update-profile-picture")]
        public async Task<IActionResult> UpdateProfilePicture(int id, [FromForm] ImageUploadRequest? request, [FromServices] IWebHostEnvironment env)
        {
            if (_authService.IsInRole(User, "Troop"))
            {
                var member = await _service.GetByIdAsync(id);
                if (member == null || !await _accessControlService.CanTroopAccessMemberAsync(User, member.Id))
                {
                    return Forbid();
                }
            }
            if (_authService.IsInRole(User, "Member"))
            {
                if (_authService.GetUserId(User) != id)
                {
                    return Forbid();
                }
            }

            if (request == null || request.Image == null || request.Image.Length == 0)
            {
                var updated = await _memberService.UpdateProfilePictureAsync(id, null);
                return Ok(updated);
            }

            var extension = Path.GetExtension(request.Image.FileName);
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };

            if (!allowedExtensions.Contains(extension.ToLower()))
                return BadRequest("Unsupported file type.");

            var folder = Path.Combine(env.WebRootPath, "images", "members");
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await request.Image.CopyToAsync(stream);
            }

            var imagePath = $"images/members/{fileName}";

            var updatedResponse = await _memberService.UpdateProfilePictureAsync(id, imagePath);

            return Ok(updatedResponse);
        }

        [HttpPost("update-categories")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateAllMemberCategories()
        {
            await _memberService.UpdateAllMemberCategoriesAsync();
            return Ok(new { message = "All member categories updated successfully." });
        }

        [HttpGet("available-members")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> GetAvailableMembers([FromQuery] MemberSearchObject? search = null)
        {
            var memberId = _authService.GetUserId(User);
            if (memberId == null)
                return Unauthorized();
            
            var result = await _memberService.GetAvailableMembersAsync(memberId.Value, search);
            return Ok(result);
        }
    }
}