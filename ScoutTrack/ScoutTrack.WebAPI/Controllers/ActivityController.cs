using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
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
                if (!await _accessControlService.CanTroopAccessActivityAsync(User, request.TroopId))
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
                if (activity == null || !await _accessControlService.CanTroopAccessActivityAsync(User, activity.TroopId))
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

        [HttpPut("{id}deactivate")]
        public virtual async Task<ActivityResponse?> DeactivateAsync(int id)
        {
            return await _activityService.DeactivateAsync(id);
        }
    }
} 