using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Database;
using ScoutTrack.Model.Requests;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] UserSearchObject search)
        {
            var users = await _userService.GetAsync(search);
            return Ok(users);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null) return NotFound();
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] UserUpsertRequest user)
        {
            var created = await _userService.CreateAsync(user);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UserUpsertRequest user)
        {
            var updated = await _userService.UpdateAsync(id, user);
            if (updated == null) return NotFound();
            return Ok(updated);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _userService.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }
    }
}