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
    public class EquipmentController : BaseCRUDController<EquipmentResponse, EquipmentSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        private readonly IAuthService _authService;

        public EquipmentController(IEquipmentService equipmentService, IAuthService authService) : base(equipmentService)
        {
            _authService = authService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Troop")]
        public override async Task<IActionResult> Create([FromBody] EquipmentUpsertRequest request)
        {
            bool isGlobal = true;
            int? createdByTroopId = null;

            if (_authService.IsInRole(User, "Troop"))
            {
                isGlobal = false;

                var troopId = _authService.GetUserId(User);
                if (troopId == null)
                    return BadRequest("Invalid user claim for Troop ID.");

                createdByTroopId = troopId;
            }

            var equipmentService = (IEquipmentService)_service;
            var result = await equipmentService.CreateWithAutoFieldsAsync(request, isGlobal, createdByTroopId);
            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Update(int id, [FromBody] EquipmentUpsertRequest request)
        {
            var existingEquipment = await _service.GetByIdAsync(id);
            if (existingEquipment == null)
                return NotFound();

            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }

        [HttpPatch("{id}/make-global")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> MakeGlobal(int id)
        {
            var equipmentService = (IEquipmentService)_service;
            var result = await equipmentService.MakeGlobalAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpGet("")]
        public override async Task<PagedResult<EquipmentResponse>> Get([FromQuery] EquipmentSearchObject? search = null)
        {
            search ??= new EquipmentSearchObject();

            if (_authService.IsInRole(User, "Troop"))
            {
                var troopId = _authService.GetUserId(User);
                if (troopId.HasValue)
                {
                    if (search.IsGlobal.HasValue && !search.IsGlobal.Value)
                    {
                        search.CreatedByTroopId = troopId.Value;
                    }
                    else if (!search.IsGlobal.HasValue)
                    {
                        search.IsGlobal = true;
                        search.CreatedByTroopId = troopId.Value;
                    }
                }
            }

        return await _service.GetAsync(search);
    }

    [HttpGet("{id}")]
    public override async Task<EquipmentResponse?> GetById(int id)
    {
        var equipment = await _service.GetByIdAsync(id);
        if (equipment == null)
            return null;

        if (_authService.IsInRole(User, "Troop"))
        {
            var troopId = _authService.GetUserId(User);
            if (troopId.HasValue)
            {
                if (!equipment.IsGlobal && equipment.CreatedByTroopId != troopId.Value)
                {
                    return null;
                }
            }
        }

        return equipment;
    }
    }
}