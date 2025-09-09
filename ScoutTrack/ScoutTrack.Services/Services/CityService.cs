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

        public override async Task<PagedResult<CityResponse>> GetAsync(CitySearchObject search)
        {
            var baseQuery = _context.Set<City>().AsQueryable();
            baseQuery = ApplyFilter(baseQuery, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await baseQuery.CountAsync();
            }

            var entities = await baseQuery.ToListAsync();

            var responseList = entities.Select(c => new CityResponse
            {
                Id = c.Id,
                Name = c.Name,
                Latitude = c.Latitude,
                Longitude = c.Longitude,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt,
                TroopCount = _context.Troops.Count(t => t.CityId == c.Id),
                MemberCount = _context.Members.Count(m => m.CityId == c.Id)
            }).ToList();

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy.ToLower();
                var descending = orderBy.StartsWith("-");
                if (descending)
                {
                    orderBy = orderBy.Substring(1);
                }

                responseList = orderBy switch
                {
                    "name" => descending
                        ? responseList.OrderByDescending(x => x.Name).ToList()
                        : responseList.OrderBy(x => x.Name).ToList(),
                    "createdat" => descending
                        ? responseList.OrderByDescending(x => x.CreatedAt).ToList()
                        : responseList.OrderBy(x => x.CreatedAt).ToList(),
                    "updatedat" => descending
                        ? responseList.OrderByDescending(x => x.UpdatedAt).ToList()
                        : responseList.OrderBy(x => x.UpdatedAt).ToList(),
                    "troopcount" => descending
                        ? responseList.OrderByDescending(x => x.TroopCount).ToList()
                        : responseList.OrderBy(x => x.TroopCount).ToList(),
                    "membercount" => descending
                        ? responseList.OrderByDescending(x => x.MemberCount).ToList()
                        : responseList.OrderBy(x => x.MemberCount).ToList(),
                    _ => responseList
                };
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                responseList = responseList
                    .Skip(search.Page.Value * search.PageSize.Value)
                    .Take(search.PageSize.Value)
                    .ToList();
            }

            return new PagedResult<CityResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }
    }
} 