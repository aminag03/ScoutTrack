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
    public class FriendshipController : BaseCRUDController<FriendshipResponse, FriendshipSearchObject, FriendshipUpsertRequest, FriendshipUpsertRequest>
    {
        private readonly IAuthService _authService;
        private readonly IFriendshipService _friendshipService;

        public FriendshipController(IFriendshipService friendshipService, IAuthService authService) : base(friendshipService)
        {
            _authService = authService;
            _friendshipService = friendshipService;
        }

        [HttpPost("send-request")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> SendFriendRequest([FromBody] SendFriendRequestRequest request)
        {
            var requesterId = _authService.GetUserId(User);
            if (requesterId == null)
                return Unauthorized();
            var result = await _friendshipService.SendFriendRequestAsync(requesterId.Value, request.ResponderId);
            return Ok(result);
        }

        [HttpPost("{id}/accept")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> AcceptFriendRequest(int id)
        {
            var responderId = _authService.GetUserId(User);
            if (responderId == null)
                return Unauthorized();
            var result = await _friendshipService.AcceptFriendRequestAsync(id, responderId.Value);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpPost("{id}/reject")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> RejectFriendRequest(int id)
        {
            var responderId = _authService.GetUserId(User);
            if (responderId == null)
                return Unauthorized();
            var result = await _friendshipService.RejectFriendRequestAsync(id, responderId.Value);
            if (!result)
                return NotFound();
            return Ok(new { message = "Friend request rejected successfully." });
        }

        [HttpDelete("{id}/unfriend")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> Unfriend(int id)
        {
            var memberId = _authService.GetUserId(User);
            if (memberId == null)
                return Unauthorized();
            var result = await _friendshipService.UnfriendAsync(id, memberId.Value);
            if (!result)
                return NotFound();
            return Ok(new { message = "Successfully unfriended." });
        }

        [HttpDelete("{id}/cancel-request")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> CancelFriendRequest(int id)
        {
            var requesterId = _authService.GetUserId(User);
            if (requesterId == null)
                return Unauthorized();
            var result = await _friendshipService.CancelFriendRequestAsync(id, requesterId.Value);
            if (!result)
                return NotFound();
            return Ok(new { message = "Friend request cancelled successfully." });
        }

        [HttpGet("my-friends")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> GetMyFriends([FromQuery] FriendshipSearchObject? search = null)
        {
            var memberId = _authService.GetUserId(User);
            if (memberId == null)
                return Unauthorized();
            search ??= new FriendshipSearchObject();
            search.MemberId = memberId;
            search.Status = ScoutTrack.Common.Enums.FriendshipStatus.Accepted;
            
            var result = await _friendshipService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("pending-requests")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> GetPendingRequests([FromQuery] FriendshipSearchObject? search = null)
        {
            var memberId = _authService.GetUserId(User);
            if (memberId == null)
                return Unauthorized();
            search ??= new FriendshipSearchObject();
            search.ResponderId = memberId;
            search.Status = ScoutTrack.Common.Enums.FriendshipStatus.Pending;
            
            var result = await _friendshipService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("sent-requests")]
        [Authorize(Roles = "Member")]
        public async Task<IActionResult> GetSentRequests([FromQuery] FriendshipSearchObject? search = null)
        {
            var memberId = _authService.GetUserId(User);
            if (memberId == null)
                return Unauthorized();
            search ??= new FriendshipSearchObject();
            search.RequesterId = memberId;
            search.Status = ScoutTrack.Common.Enums.FriendshipStatus.Pending;
            
            var result = await _friendshipService.GetAsync(search);
            return Ok(result);
        }
    }

    public class SendFriendRequestRequest
    {
        public int ResponderId { get; set; }
    }
}
