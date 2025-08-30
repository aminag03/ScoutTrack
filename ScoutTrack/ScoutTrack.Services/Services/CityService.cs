using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class CityService : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        private readonly ScoutTrackDbContext _context;

        public CityService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(pt => pt.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(pt => pt.Name.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name))
                throw new UserException("City with this name already exists.");
        }

        protected override async Task BeforeUpdate(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
                throw new UserException("City with this name already exists.");
        }

        protected override void MapUpdateToEntity(City entity, CityUpsertRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
            base.MapUpdateToEntity(entity, request);
        }

        protected override async Task BeforeDelete(City entity)
        {
            var hasTroops = await _context.Troops.AnyAsync(t => t.CityId == entity.Id);
            var hasMembers = await _context.Members.AnyAsync(m => m.CityId == entity.Id);
            if (hasTroops || hasMembers)
                throw new UserException("Cannot delete city: it is referenced by one or more Troops or Members.");
        }
    }
} 