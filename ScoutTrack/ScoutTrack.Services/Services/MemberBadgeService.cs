using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Exceptions;
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
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class MemberBadgeService : BaseCRUDService<MemberBadgeResponse, MemberBadgeSearchObject, MemberBadge, MemberBadgeUpsertRequest, MemberBadgeUpsertRequest>, IMemberBadgeService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<MemberBadgeService> _logger;

        public MemberBadgeService(ScoutTrackDbContext context, IMapper mapper, ILogger<MemberBadgeService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        public override async Task<PagedResult<MemberBadgeResponse>> GetAsync(MemberBadgeSearchObject search)
        {
            var query = _context.Set<MemberBadge>()
                .Include(mb => mb.Member)
                .Include(mb => mb.Badge)
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
                    var propertyName = search.OrderBy[1..];
                    query = _applySorting(query, propertyName, descending: true);
                }
                else
                {
                    query = _applySorting(query, search.OrderBy, descending: false);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<MemberBadgeResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<List<MemberBadgeResponse>> GetMembersByBadgeStatusAsync(int badgeId, MemberBadgeStatus status)
        {
            var query = _context.Set<MemberBadge>()
                .Include(mb => mb.Member)
                .Include(mb => mb.Badge)
                .Where(mb => mb.BadgeId == badgeId && mb.Status == status)
                .OrderBy(mb => mb.Member.FirstName)
                .ThenBy(mb => mb.Member.LastName);

            var list = await query.ToListAsync();
            return list.Select(MapToResponse).ToList();
        }

        public async Task<List<MemberBadgeResponse>> GetMembersByBadgeStatusAndTroopAsync(int badgeId, MemberBadgeStatus status, int troopId)
        {
            var query = _context.Set<MemberBadge>()
                .Include(mb => mb.Member)
                .Include(mb => mb.Badge)
                .Where(mb => mb.BadgeId == badgeId && mb.Status == status && mb.Member.TroopId == troopId)
                .OrderBy(mb => mb.Member.FirstName)
                .ThenBy(mb => mb.Member.LastName);

            var list = await query.ToListAsync();
            return list.Select(MapToResponse).ToList();
        }

        public async Task<bool> CompleteMemberBadgeAsync(int memberBadgeId)
        {
            var memberBadge = await _context.MemberBadges
                .Include(mb => mb.Badge)
                .FirstOrDefaultAsync(mb => mb.Id == memberBadgeId);

            if (memberBadge == null)
                throw new UserException("Member badge not found.");

            var allRequirements = await _context.BadgeRequirements
                .Where(br => br.BadgeId == memberBadge.BadgeId)
                .ToListAsync();

            var completedProgress = await _context.MemberBadgeProgresses
                .Where(mbp => mbp.MemberBadgeId == memberBadgeId && mbp.IsCompleted)
                .ToListAsync();

            if (completedProgress.Count != allRequirements.Count)
                throw new UserException("All requirements must be completed before marking badge as completed.");

            memberBadge.Status = MemberBadgeStatus.Completed;
            memberBadge.CompletedAt = DateTime.UtcNow;
            memberBadge.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task SyncProgressRecordsForBadge(int badgeId)
        {
            var memberBadges = await _context.MemberBadges
                .Where(mb => mb.BadgeId == badgeId)
                .ToListAsync();

            var badgeRequirements = await _context.BadgeRequirements
                .Where(br => br.BadgeId == badgeId)
                .ToListAsync();

            foreach (var memberBadge in memberBadges)
            {
                var existingProgress = await _context.MemberBadgeProgresses
                    .Where(mbp => mbp.MemberBadgeId == memberBadge.Id)
                    .ToListAsync();

                var missingRequirements = badgeRequirements
                    .Where(req => !existingProgress.Any(p => p.RequirementId == req.Id))
                    .ToList();

                var newProgressRecords = missingRequirements.Select(req => new MemberBadgeProgress
                {
                    MemberBadgeId = memberBadge.Id,
                    RequirementId = req.Id,
                    IsCompleted = false,
                    CompletedAt = null
                }).ToList();

                if (newProgressRecords.Any())
                {
                    _context.MemberBadgeProgresses.AddRange(newProgressRecords);
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task SyncProgressRecordsForBadgeAndTroop(int badgeId, int troopId)
        {
            var memberBadges = await _context.MemberBadges
                .Include(mb => mb.Member)
                .Where(mb => mb.BadgeId == badgeId && mb.Member.TroopId == troopId)
                .ToListAsync();

            var badgeRequirements = await _context.BadgeRequirements
                .Where(br => br.BadgeId == badgeId)
                .ToListAsync();

            foreach (var memberBadge in memberBadges)
            {
                var existingProgress = await _context.MemberBadgeProgresses
                    .Where(mbp => mbp.MemberBadgeId == memberBadge.Id)
                    .ToListAsync();

                var missingRequirements = badgeRequirements
                    .Where(req => !existingProgress.Any(p => p.RequirementId == req.Id))
                    .ToList();

                var newProgressRecords = missingRequirements.Select(req => new MemberBadgeProgress
                {
                    MemberBadgeId = memberBadge.Id,
                    RequirementId = req.Id,
                    IsCompleted = false,
                    CompletedAt = null
                }).ToList();

                if (newProgressRecords.Any())
                {
                    _context.MemberBadgeProgresses.AddRange(newProgressRecords);
                }
            }

            await _context.SaveChangesAsync();
        }

        protected override IQueryable<MemberBadge> ApplyFilter(IQueryable<MemberBadge> query, MemberBadgeSearchObject search)
        {
            if (search.MemberId.HasValue)
            {
                query = query.Where(mb => mb.MemberId == search.MemberId.Value);
            }

            if (search.BadgeId.HasValue)
            {
                query = query.Where(mb => mb.BadgeId == search.BadgeId.Value);
            }

            if (search.Status.HasValue)
            {
                query = query.Where(mb => mb.Status == search.Status.Value);
            }

            if (search.TroopId.HasValue)
            {
                query = query.Where(mb => mb.Member.TroopId == search.TroopId.Value);
            }

            if (!string.IsNullOrEmpty(search.MemberName))
            {
                query = query.Where(mb => 
                    mb.Member.FirstName.Contains(search.MemberName) || 
                    mb.Member.LastName.Contains(search.MemberName));
            }

            if (!string.IsNullOrEmpty(search.BadgeName))
            {
                query = query.Where(mb => mb.Badge.Name.Contains(search.BadgeName));
            }

            return query;
        }

        private IQueryable<MemberBadge> _applySorting(IQueryable<MemberBadge> query, string propertyName, bool descending)
        {
            switch (propertyName.ToLower())
            {
                case "memberfirstname":
                    return descending 
                        ? query.OrderByDescending(mb => mb.Member.FirstName)
                        : query.OrderBy(mb => mb.Member.FirstName);
                
                case "badgename":
                    return descending 
                        ? query.OrderByDescending(mb => mb.Badge.Name)
                        : query.OrderBy(mb => mb.Badge.Name);
                
                case "createdat":
                    return descending 
                        ? query.OrderByDescending(mb => mb.CreatedAt)
                        : query.OrderBy(mb => mb.CreatedAt);
                
                case "completedat":
                    return descending 
                        ? query.OrderByDescending(mb => mb.CompletedAt)
                        : query.OrderBy(mb => mb.CompletedAt);
                
                case "status":
                    return descending 
                        ? query.OrderByDescending(mb => mb.Status)
                        : query.OrderBy(mb => mb.Status);
                
                default:
                    return query.OrderBy(mb => mb.Member.FirstName).ThenBy(mb => mb.Member.LastName);
            }
        }

        protected override async Task BeforeInsert(MemberBadge entity, MemberBadgeUpsertRequest request)
        {
            if (await _context.MemberBadges.AnyAsync(mb => 
                mb.MemberId == request.MemberId && mb.BadgeId == request.BadgeId))
            {
                throw new UserException("Member already has this badge.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        public override async Task<MemberBadgeResponse> CreateAsync(MemberBadgeUpsertRequest request)
        {
            var response = await base.CreateAsync(request);
            
            var badgeRequirements = await _context.BadgeRequirements
                .Where(br => br.BadgeId == request.BadgeId)
                .ToListAsync();

            var progressRecords = badgeRequirements.Select(req => new MemberBadgeProgress
            {
                MemberBadgeId = response.Id,
                RequirementId = req.Id,
                IsCompleted = false,
                CompletedAt = null
            }).ToList();

            if (progressRecords.Any())
            {
                _context.MemberBadgeProgresses.AddRange(progressRecords);
                await _context.SaveChangesAsync();
            }

            return response;
        }

        protected override async Task BeforeUpdate(MemberBadge entity, MemberBadgeUpsertRequest request)
        {
            if (await _context.MemberBadges.AnyAsync(mb => 
                mb.MemberId == request.MemberId && 
                mb.BadgeId == request.BadgeId && 
                mb.Id != entity.Id))
            {
                throw new UserException("Member already has this badge.");
            }

            entity.UpdatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeDelete(MemberBadge entity)
        {
            var progressRecords = await _context.MemberBadgeProgresses
                .Where(mbp => mbp.MemberBadgeId == entity.Id)
                .ToListAsync();

            if (progressRecords.Any())
            {
                _context.MemberBadgeProgresses.RemoveRange(progressRecords);
                await _context.SaveChangesAsync();
            }
        }

        protected override MemberBadgeResponse MapToResponse(MemberBadge entity)
        {
            return new MemberBadgeResponse
            {
                Id = entity.Id,
                MemberId = entity.MemberId,
                MemberFirstName = entity.Member?.FirstName ?? string.Empty,
                MemberLastName = entity.Member?.LastName ?? string.Empty,
                MemberProfilePictureUrl = entity.Member?.ProfilePictureUrl ?? string.Empty,
                BadgeId = entity.BadgeId,
                BadgeName = entity.Badge?.Name ?? string.Empty,
                BadgeImageUrl = entity.Badge?.ImageUrl ?? string.Empty,
                Status = entity.Status,
                CompletedAt = entity.CompletedAt,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }
    }
}
