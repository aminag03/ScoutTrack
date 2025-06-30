using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;

namespace ScoutTrack.WebAPI.Controllers
{
   // [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("[controller]")]
    public class AdminController : BaseCRUDController<AdminResponse, AdminSearchObject, AdminUpsertRequest, AdminUpsertRequest>
    {
        public AdminController(IAdminService adminService) : base(adminService)
        {
        }
    }
} 