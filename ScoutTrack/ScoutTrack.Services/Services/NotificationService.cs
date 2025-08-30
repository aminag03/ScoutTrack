using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System.Security.Claims;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ScoutTrack.Model.Exceptions;

namespace ScoutTrack.Services
{
    public class NotificationService : BaseCRUDService<NotificationResponse, NotificationSearchObject, Notification, NotificationUpsertRequest, NotificationUpsertRequest>, INotificationService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<NotificationService> _logger;
        private readonly IAuthService _authService;

        public NotificationService(ScoutTrackDbContext context, IMapper mapper, ILogger<NotificationService> logger, IAuthService authService) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _authService = authService;
        }

        public override async Task<PagedResult<NotificationResponse>> GetAsync(NotificationSearchObject search)
        {
            var query = _context.Set<Notification>()
                .Include(n => n.Receiver)
                .Include(n => n.Sender)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;
                bool descending = orderBy.StartsWith("-");
                if (descending) orderBy = orderBy[1..];

                query = orderBy.ToLower() switch
                {
                    "createdat" => descending
                        ? query.OrderByDescending(n => n.CreatedAt)
                        : query.OrderBy(n => n.CreatedAt),
                    "message" => descending
                        ? query.OrderByDescending(n => n.Message)
                        : query.OrderBy(n => n.Message),
                    "isread" => descending
                        ? query.OrderByDescending(n => n.IsRead)
                        : query.OrderBy(n => n.IsRead),
                    _ => query
                };
            }
            else
            {
                query = query.OrderByDescending(n => n.CreatedAt);
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query
                    .Skip(search.Page.Value * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var entities = await query.ToListAsync();
            var responseList = _mapper.Map<List<NotificationResponse>>(entities);

            return new PagedResult<NotificationResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Notification> ApplyFilter(IQueryable<Notification> query, NotificationSearchObject search)
        {
            if (search.ReceiverId.HasValue)
            {
                query = query.Where(n => n.ReceiverId == search.ReceiverId.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(n => n.IsRead == search.IsRead.Value);
            }

            if (!string.IsNullOrEmpty(search.Message))
            {
                query = query.Where(n => n.Message.Contains(search.Message));
            }

            return query;
        }

        public async Task<List<NotificationResponse>> SendNotificationsToUsersAsync(NotificationUpsertRequest request, int senderId)
        {
            // Validate that all receiver IDs exist in UserAccount table
            var existingUserIds = await _context.UserAccounts
                .Where(u => request.UserIds.Contains(u.Id))
                .Select(u => u.Id)
                .ToListAsync();

            if (existingUserIds.Count != request.UserIds.Count)
            {
                var missingIds = request.UserIds.Except(existingUserIds).ToList();
                throw new UserException($"Invalid receiver IDs: {string.Join(", ", missingIds)}. These users do not exist.");
            }

            // Validate that sender ID exists
            var senderExists = await _context.UserAccounts.AnyAsync(u => u.Id == senderId);
            if (!senderExists)
            {
                throw new UserException($"Invalid sender ID: {senderId}. Sender does not exist.");
            }

            var notifications = new List<Notification>();
            var now = DateTime.Now;

            foreach (var userId in request.UserIds)
            {
                var notification = new Notification
                {
                    Message = request.Message,
                    ReceiverId = userId,
                    SenderId = senderId,
                    CreatedAt = now,
                    IsRead = false
                };

                notifications.Add(notification);
            }

            await _context.Notifications.AddRangeAsync(notifications);
            await _context.SaveChangesAsync();

            var responseList = _mapper.Map<List<NotificationResponse>>(notifications);
            return responseList;
        }

        public async Task<bool> MarkAsReadAsync(int id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null)
                return false;

            notification.IsRead = true;
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> MarkAllAsReadAsync(int userId)
        {
            var unreadNotifications = await _context.Notifications
                .Where(n => n.ReceiverId == userId && !n.IsRead)
                .ToListAsync();

            if (!unreadNotifications.Any())
                return true;

            foreach (var notification in unreadNotifications)
            {
                notification.IsRead = true;
            }

            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _context.Notifications
                .CountAsync(n => n.ReceiverId == userId && !n.IsRead);
        }

        public async Task<PagedResult<NotificationResponse>> GetForUserAsync(ClaimsPrincipal user, NotificationSearchObject search)
        {
            var userId = _authService.GetUserId(user);
            if (!userId.HasValue)
            {
                throw new UserException("User ID not found in authentication token");
            }
            search.ReceiverId = userId.Value;
            return await GetAsync(search);
        }

        public async Task<bool> MarkAsReadForUserAsync(ClaimsPrincipal user, int id)
        {
            var userId = _authService.GetUserId(user);
            if (!userId.HasValue)
            {
                throw new UserException("User ID not found in authentication token");
            }
            
            var notification = await _context.Notifications
                .FirstOrDefaultAsync(n => n.Id == id && n.ReceiverId == userId.Value);
            
            if (notification == null)
                return false;

            notification.IsRead = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MarkAllAsReadForUserAsync(ClaimsPrincipal user)
        {
            var userId = _authService.GetUserId(user);
            if (!userId.HasValue)
            {
                throw new UserException("User ID not found in authentication token");
            }
            
            var unreadNotifications = await _context.Notifications
                .Where(n => n.ReceiverId == userId.Value && !n.IsRead)
                .ToListAsync();

            if (!unreadNotifications.Any())
                return true;

            foreach (var notification in unreadNotifications)
            {
                notification.IsRead = true;
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetUnreadCountForUserAsync(ClaimsPrincipal user)
        {
            var userId = _authService.GetUserId(user);
            if (!userId.HasValue)
            {
                throw new UserException("User ID not found in authentication token");
            }
            return await GetUnreadCountAsync(userId.Value);
        }

        public async Task<bool> DeleteAllNotificationsForUserAsync(ClaimsPrincipal user)
        {
            var userId = _authService.GetUserId(user);
            if (!userId.HasValue)
            {
                throw new UserException("User ID not found in authentication token");
            }
            
            var userNotifications = await _context.Notifications
                .Where(n => n.ReceiverId == userId.Value)
                .ToListAsync();
            
            if (!userNotifications.Any())
                return true;

            _context.Notifications.RemoveRange(userNotifications);
            await _context.SaveChangesAsync();
            return true;
        }

        protected Notification MapToEntity(NotificationUpsertRequest request)
        {
            return new Notification
            {
                Message = request.Message,
                ReceiverId = request.UserIds.FirstOrDefault(),
                CreatedAt = DateTime.Now,
                IsRead = false
            };
        }

        protected void MapToEntity(NotificationUpsertRequest request, Notification entity)
        {
            entity.Message = request.Message;
            entity.IsRead = false;
        }


    }
}
