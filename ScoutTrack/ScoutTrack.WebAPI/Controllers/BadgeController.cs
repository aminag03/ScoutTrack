using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Database;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BadgeController : ControllerBase
    {
        private readonly IBadgeService _badgeService;

        public BadgeController(IBadgeService badgeService)
        {
            _badgeService = badgeService;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] BadgeSearchObject search)
        {
            var badges = await _badgeService.GetAsync(search);
            return Ok(badges);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var badge = await _badgeService.GetByIdAsync(id);
            if (badge == null)
                return NotFound();

            return Ok(badge);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] BadgeUpsertRequest request)
        {
            var created = await _badgeService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] BadgeUpsertRequest request)
        {
            var updated = await _badgeService.UpdateAsync(id, request);
            if (updated == null)
                return NotFound();

            return Ok(updated);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _badgeService.DeleteAsync(id);
            if (!deleted)
                return NotFound();

            return NoContent();
        }
    }
}
