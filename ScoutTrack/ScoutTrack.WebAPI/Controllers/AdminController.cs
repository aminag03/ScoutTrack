using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : BaseCRUDController<AdminResponse, AdminSearchObject, AdminInsertRequest, AdminUpdateRequest>
    {
        public AdminController(IAdminService adminService) : base(adminService)
        {
        }
    }
} 