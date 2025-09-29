using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Hosting;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Extensions;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class BadgeService : BaseCRUDService<BadgeResponse, BadgeSearchObject, Badge, BadgeUpsertRequest, BadgeUpsertRequest>, IBadgeService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<BadgeService> _logger;
        private readonly IWebHostEnvironment _env;

        public BadgeService(ScoutTrackDbContext context, IMapper mapper, ILogger<BadgeService> logger, IWebHostEnvironment env) : base(context, mapper) 
        {
            _context = context;
            _logger = logger;
            _env = env;
        }

        public override async Task<PagedResult<BadgeResponse>> GetAsync(BadgeSearchObject search)
        {
            var query = _context.Set<Badge>()
                .Include(b => b.MemberBadges)
                    .ThenInclude(mb => mb.Member)
                .AsQueryable();
            
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                if (search.OrderBy.Equals("popularity", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.OrderByDescending(b => b.MemberBadges.Count);
                }
                else if (search.OrderBy.Equals("-popularity", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.OrderBy(b => b.MemberBadges.Count);
                }
                else if (search.OrderBy.Equals("name", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.OrderBy(b => b.Name);
                }
                else if (search.OrderBy.Equals("-name", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.OrderByDescending(b => b.Name);
                }
                else if (search.OrderBy.StartsWith("-"))
                {
                    query = query.OrderByDescendingDynamic(search.OrderBy[1..]);
                }
                else
                {
                    query = query.OrderByDynamic(search.OrderBy);
                }
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

            var list = await query.ToListAsync();
            return new PagedResult<BadgeResponse>
            {
                Items = list.Select(entity => MapToResponse(entity, search.TroopId)).ToList(),
                TotalCount = totalCount
            };
        }

        protected override BadgeResponse MapToResponse(Badge entity)
        {
            return MapToResponse(entity, null);
        }

        protected BadgeResponse MapToResponse(Badge entity, int? troopId)
        {
            var response = _mapper.Map<BadgeResponse>(entity);
            
            var relevantMemberBadges = entity.MemberBadges;
            if (troopId.HasValue)
            {
                relevantMemberBadges = entity.MemberBadges.Where(mb => mb.Member.TroopId == troopId.Value).ToList();
            }
            
            response.TotalMemberBadges = relevantMemberBadges.Count;
            response.CompletedMemberBadges = relevantMemberBadges.Count(mb => mb.Status == Common.Enums.MemberBadgeStatus.Completed);
            response.InProgressMemberBadges = relevantMemberBadges.Count(mb => mb.Status == Common.Enums.MemberBadgeStatus.InProgress);
            
            return response;
        }

        protected override IQueryable<Badge> ApplyFilter(IQueryable<Badge> query, BadgeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(pt => pt.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(pt => pt.Name.Contains(search.FTS) || pt.Description.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(Badge entity, BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name))
                throw new UserException("Badge with this name already exists.");
        }

        protected override async Task BeforeUpdate(Badge entity, BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name && b.Id != entity.Id))
                throw new UserException("Badge with this name already exists.");

            if (!string.IsNullOrEmpty(entity.ImageUrl) && entity.ImageUrl != request.ImageUrl)
            {
                DeleteImageFile(entity.ImageUrl);
            }
        }

        protected override async Task BeforeDelete(Badge entity)
        {
            var memberBadges = await _context.MemberBadges
                .Where(mb => mb.BadgeId == entity.Id)
                .ToListAsync();

            if (memberBadges.Any())
            {
                var memberBadgeIds = memberBadges.Select(mb => mb.Id).ToList();
                var progressRecords = await _context.MemberBadgeProgresses
                    .Where(mbp => memberBadgeIds.Contains(mbp.MemberBadgeId))
                    .ToListAsync();

                if (progressRecords.Any())
                {
                    _context.MemberBadgeProgresses.RemoveRange(progressRecords);
                }

                _context.MemberBadges.RemoveRange(memberBadges);
            }

            var requirements = await _context.BadgeRequirements
                .Where(br => br.BadgeId == entity.Id)
                .ToListAsync();
            
            if (requirements.Any())
            {
                _context.BadgeRequirements.RemoveRange(requirements);
            }
            
            if (!string.IsNullOrEmpty(entity.ImageUrl))
            {
                DeleteImageFile(entity.ImageUrl);
            }

            await _context.SaveChangesAsync();
        }

        private void DeleteImageFile(string imageUrl)
        {
            if (string.IsNullOrWhiteSpace(imageUrl))
                return;

            try
            {
                string relativePath;
                if (imageUrl.StartsWith("http"))
                {
                    var uri = new Uri(imageUrl);
                    relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                }
                else
                {
                    relativePath = imageUrl.Replace('/', Path.DirectorySeparatorChar);
                }
                
                var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                    _logger.LogInformation($"Deleted badge image file: {fullPath}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error while deleting badge image file: {imageUrl}", imageUrl);
            }
        }
    }
}