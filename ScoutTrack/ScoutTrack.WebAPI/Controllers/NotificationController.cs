using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Model.Exceptions;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class NotificationController : BaseCRUDController<NotificationResponse, NotificationSearchObject, NotificationUpsertRequest, NotificationUpsertRequest>
    {
        private readonly INotificationService _notificationService;
        private readonly IAuthService _authService;

        public NotificationController(INotificationService notificationService, IAuthService authService) : base(notificationService)
        {
            _notificationService = notificationService;
            _authService = authService;
        }



        [HttpPost("send-to-users")]
        public async Task<ActionResult<List<NotificationResponse>>> SendNotificationsToUsers([FromBody] NotificationUpsertRequest request)
        {
            try
            {
                if (request.UserIds == null || !request.UserIds.Any())
                {
                    return BadRequest("User IDs are required");
                }

                var currentUserId = _authService.GetUserId(User);
                if (!currentUserId.HasValue)
                {
                    return BadRequest("User ID not found in authentication token");
                }

                // Additional validation: ensure the current user is not trying to send notifications to themselves
                if (request.UserIds.Contains(currentUserId.Value))
                {
                    return BadRequest("Cannot send notifications to yourself");
                }

                var result = await _notificationService.SendNotificationsToUsersAsync(request, currentUserId.Value);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while sending notifications");
            }
        }

        [HttpPatch("{id}/mark-as-read")]
        public async Task<ActionResult<bool>> MarkAsRead(int id)
        {
            try
            {
                var result = await _notificationService.MarkAsReadForUserAsync(User, id);
                if (!result)
                    return NotFound();

                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while marking notification as read");
            }
        }

        [HttpPatch("mark-all-as-read")]
        public async Task<ActionResult<bool>> MarkAllAsRead()
        {
            try
            {
                var result = await _notificationService.MarkAllAsReadForUserAsync(User);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while marking all notifications as read");
            }
        }

        [HttpGet("unread-count")]
        public async Task<ActionResult<int>> GetUnreadCount()
        {
            try
            {
                var count = await _notificationService.GetUnreadCountForUserAsync(User);
                return Ok(count);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while getting unread count");
            }
        }

        [HttpGet("my-notifications")]
        public async Task<ActionResult<PagedResult<NotificationResponse>>> GetMyNotifications([FromQuery] NotificationSearchObject search)
        {
            try
            {
                var result = await _notificationService.GetForUserAsync(User, search);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while getting notifications");
            }
        }

        [HttpDelete("delete-all")]
        public async Task<ActionResult<bool>> DeleteAllNotifications()
        {
            try
            {
                var result = await _notificationService.DeleteAllNotificationsForUserAsync(User);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An unexpected error occurred while deleting all notifications");
            }
        }
    }
}
