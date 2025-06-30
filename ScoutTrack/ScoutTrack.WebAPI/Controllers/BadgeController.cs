using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Database;

namespace ScoutTrack.WebAPI.Controllers
{
    [Authorize(Roles = "Member")]
    [ApiController]
    [Route("[controller]")]
    public class BadgeController : BaseCRUDController<BadgeResponse, BadgeSearchObject, BadgeUpsertRequest, BadgeUpsertRequest>
    {
        public BadgeController(IBadgeService badgeService) : base(badgeService)
        {
        }
    }
}
