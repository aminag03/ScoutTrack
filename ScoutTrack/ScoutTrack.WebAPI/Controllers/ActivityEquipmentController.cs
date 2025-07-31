using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ActivityEquipmentController : BaseCRUDController<ActivityEquipmentResponse, ActivityEquipmentSearchObject, ActivityEquipmentUpsertRequest, ActivityEquipmentUpsertRequest>
    {
        private readonly IActivityEquipmentService _activityEquipmentService;

        public ActivityEquipmentController(IActivityEquipmentService activityEquipmentService) : base(activityEquipmentService)
        {
            _activityEquipmentService = activityEquipmentService;
        }

        [HttpGet("activity/{activityId}")]
        public async Task<ActionResult<List<ActivityEquipmentResponse>>> GetByActivityId(int activityId)
        {
            try
            {
                var result = await _activityEquipmentService.GetByActivityIdAsync(activityId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("activity/{activityId}/equipment/{equipmentId}")]
        public async Task<ActionResult<bool>> RemoveByActivityIdAndEquipmentId(int activityId, int equipmentId)
        {
            try
            {
                var result = await _activityEquipmentService.RemoveByActivityIdAndEquipmentIdAsync(activityId, equipmentId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
} 