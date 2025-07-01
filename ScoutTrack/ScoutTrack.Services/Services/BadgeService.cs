using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class BadgeService : BaseCRUDService<BadgeResponse, BadgeSearchObject, Badge, BadgeUpsertRequest, BadgeUpsertRequest>, IBadgeService
    {
        private readonly ScoutTrackDbContext _context;

        public BadgeService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper) 
        {
            _context = context;
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
                throw new System.Exception("Badge with this name already exists.");
        }

        protected override async Task BeforeUpdate(Badge entity, BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name && b.Id != entity.Id))
                throw new System.Exception("Badge with this name already exists.");
        }
    }
}