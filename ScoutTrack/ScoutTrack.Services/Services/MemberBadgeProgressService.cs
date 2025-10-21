using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class MemberBadgeProgressService : BaseCRUDService<MemberBadgeProgressResponse, MemberBadgeProgressSearchObject, MemberBadgeProgress, MemberBadgeProgressUpsertRequest, MemberBadgeProgressUpsertRequest>, IMemberBadgeProgressService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<MemberBadgeProgressService> _logger;
        private readonly INotificationPublisherService _notificationPublisher;

        public MemberBadgeProgressService(ScoutTrackDbContext context, IMapper mapper, ILogger<MemberBadgeProgressService> logger, INotificationPublisherService notificationPublisher) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _notificationPublisher = notificationPublisher;
        }

        public override async Task<PagedResult<MemberBadgeProgressResponse>> GetAsync(MemberBadgeProgressSearchObject search)
        {
            var query = _context.Set<MemberBadgeProgress>()
                .Include(mbp => mbp.MemberBadge)
                .Include(mbp => mbp.Requirement)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                if (search.OrderBy.StartsWith("-"))
                {
                    query = query.OrderByDescendingDynamic(search.OrderBy[1..]);
                }
                else
                {
                    query = query.OrderByDynamic(search.OrderBy);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<MemberBadgeProgressResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<List<MemberBadgeProgressResponse>> GetByMemberBadgeIdAsync(int memberBadgeId)
        {
            var query = _context.Set<MemberBadgeProgress>()
                .Include(mbp => mbp.Requirement)
                .Where(mbp => mbp.MemberBadgeId == memberBadgeId)
                .OrderBy(mbp => mbp.Requirement.Description);

            var list = await query.ToListAsync();
            return list.Select(MapToResponse).ToList();
        }

        public async Task<bool> UpdateProgressCompletionAsync(int memberBadgeProgressId, bool isCompleted)
        {
            var progress = await _context.MemberBadgeProgresses
                .Include(mbp => mbp.MemberBadge)
                    .ThenInclude(mb => mb.Member)
                .Include(mbp => mbp.MemberBadge)
                    .ThenInclude(mb => mb.Badge)
                .Include(mbp => mbp.Requirement)
                .FirstOrDefaultAsync(mbp => mbp.Id == memberBadgeProgressId);

            if (progress == null)
                throw new Exception("Progress record not found.");

            var wasCompleted = progress.IsCompleted;
            progress.IsCompleted = isCompleted;
            progress.CompletedAt = isCompleted ? DateTime.Now : null;

            await _context.SaveChangesAsync();

            if (progress.MemberBadge?.Member != null)
            {
                try
                {
                    var member = progress.MemberBadge.Member;
                    var badge = progress.MemberBadge.Badge;
                    var requirement = progress.Requirement;

                    string notificationMessage;
                    if (isCompleted && !wasCompleted)
                    {
                        notificationMessage = $"Vaš napredak na vještarstvu '{badge?.Name}' je ažuriran. Uslov '{requirement?.Description}' je označen kao završen.";
                    }
                    else if (!isCompleted && wasCompleted)
                    {
                        notificationMessage = $"Vaš napredak na vještarstvu '{badge?.Name}' je ažuriran. Uslov '{requirement?.Description}' je označen kao nezavršen.";
                    }
                    else
                    {
                        return true;
                    }

                    var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                    {
                        Message = notificationMessage,
                        UserIds = new List<int> { member.Id },
                        SenderId = member.Id,
                        CreatedAt = DateTime.Now,
                        NotificationType = "BadgeProgressUpdated"
                    };

                    await _notificationPublisher.PublishNotificationAsync(notificationEvent);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error sending notification for badge progress update");
                }
            }

            return true;
        }

        protected override IQueryable<MemberBadgeProgress> ApplyFilter(IQueryable<MemberBadgeProgress> query, MemberBadgeProgressSearchObject search)
        {
            if (search.MemberBadgeId.HasValue)
            {
                query = query.Where(mbp => mbp.MemberBadgeId == search.MemberBadgeId.Value);
            }

            if (search.RequirementId.HasValue)
            {
                query = query.Where(mbp => mbp.RequirementId == search.RequirementId.Value);
            }

            if (search.IsCompleted.HasValue)
            {
                query = query.Where(mbp => mbp.IsCompleted == search.IsCompleted.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(MemberBadgeProgress entity, MemberBadgeProgressUpsertRequest request)
        {
            if (await _context.MemberBadgeProgresses.AnyAsync(mbp => 
                mbp.MemberBadgeId == request.MemberBadgeId && mbp.RequirementId == request.RequirementId))
            {
                throw new Exception("Progress already exists for this member badge and requirement.");
            }
        }

        protected override async Task BeforeUpdate(MemberBadgeProgress entity, MemberBadgeProgressUpsertRequest request)
            {
            if (await _context.MemberBadgeProgresses.AnyAsync(mbp => 
                mbp.MemberBadgeId == request.MemberBadgeId && 
                mbp.RequirementId == request.RequirementId && 
                mbp.Id != entity.Id))
            {
                throw new Exception("Progress already exists for this member badge and requirement.");
            }
        }

        protected override async Task BeforeDelete(MemberBadgeProgress entity)
        {
            try
            {
                var progress = await _context.MemberBadgeProgresses
                    .Include(mbp => mbp.MemberBadge)
                        .ThenInclude(mb => mb.Member)
                    .Include(mbp => mbp.MemberBadge)
                        .ThenInclude(mb => mb.Badge)
                    .Include(mbp => mbp.Requirement)
                    .FirstOrDefaultAsync(mbp => mbp.Id == entity.Id);

                if (progress?.MemberBadge?.Member != null && progress.MemberBadge.Badge != null && progress.Requirement != null)
                {
                    var notificationMessage = $"Uslov '{progress.Requirement.Description}' je uklonjen sa vještarstva '{progress.MemberBadge.Badge.Name}'.";

                    var notificationEvent = new ScoutTrack.Model.Events.NotificationEvent
                    {
                        Message = notificationMessage,
                        UserIds = new List<int> { progress.MemberBadge.Member.Id },
                        SenderId = progress.MemberBadge.Member.Id,
                        CreatedAt = DateTime.Now,
                        NotificationType = "BadgeProgressDeleted"
                    };

                    await _notificationPublisher.PublishNotificationAsync(notificationEvent);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending notification for badge progress deletion");
            }
        }

        protected override MemberBadgeProgressResponse MapToResponse(MemberBadgeProgress entity)
        {
            return new MemberBadgeProgressResponse
            {
                Id = entity.Id,
                MemberBadgeId = entity.MemberBadgeId,
                RequirementId = entity.RequirementId,
                RequirementDescription = entity.Requirement?.Description ?? string.Empty,
                IsCompleted = entity.IsCompleted,
                CompletedAt = entity.CompletedAt
            };
        }
    }
}
