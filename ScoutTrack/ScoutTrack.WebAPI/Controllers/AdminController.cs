using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : BaseCRUDController<AdminResponse, AdminSearchObject, AdminInsertRequest, AdminUpdateRequest>
    {
        private readonly IAuthService _authService;
        private readonly IAdminService _adminService;

        public AdminController(IAdminService adminService, IAuthService authService) : base(adminService)
        {
            _authService = authService;
            _adminService = adminService;
        }

        [HttpPatch("{id}/change-password")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            if (_authService.GetUserId(User) != id)
            {
                return Forbid();
            }

            var result = await _adminService.ChangePasswordAsync(id, request);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
    }
} 