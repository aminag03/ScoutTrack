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
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class EquipmentService : BaseCRUDService<EquipmentResponse, EquipmentSearchObject, Equipment, EquipmentUpsertRequest, EquipmentUpsertRequest>, IEquipmentService
    {
        private readonly ScoutTrackDbContext _context;

        public EquipmentService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<Equipment> ApplyFilter(IQueryable<Equipment> query, EquipmentSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(e => e.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(e => e.Name.Contains(search.FTS) || e.Description.Contains(search.FTS));
            }

            if (search.IsGlobal.HasValue)
            {
                if (search.IsGlobal.Value)
                {
                    query = query.Where(e => e.IsGlobal);
                }
                else
                {
                    if (search.CreatedByTroopId.HasValue)
                    {
                        query = query.Where(e => !e.IsGlobal && e.CreatedByTroopId == search.CreatedByTroopId.Value);
                    }
                    else
                    {
                        query = query.Where(e => !e.IsGlobal);
                    }
                }
            }
            else if (search.CreatedByTroopId.HasValue)
            {
                query = query.Where(e => e.IsGlobal || e.CreatedByTroopId == search.CreatedByTroopId.Value);
            }

            return query;
        }



        protected override async Task BeforeInsert(Equipment entity, EquipmentUpsertRequest request)
        {
            if (await _context.Equipments.AnyAsync(at => at.Name.ToLower() == request.Name.ToLower()))
                throw new UserException("Equipment with this name already exists.");
        }

        public async Task<EquipmentResponse> CreateWithAutoFieldsAsync(EquipmentUpsertRequest request, bool isGlobal, int? createdByTroopId)
        {
            var entity = new Equipment();
            _mapper.Map(request, entity);
            
            entity.IsGlobal = isGlobal;
            entity.CreatedByTroopId = createdByTroopId;
            
            await BeforeInsert(entity, request);
            
            _context.Equipments.Add(entity);
            await _context.SaveChangesAsync();
            
            return _mapper.Map<EquipmentResponse>(entity);
        }

        protected override async Task BeforeUpdate(Equipment entity, EquipmentUpsertRequest request)
        {
            if (await _context.Equipments.AnyAsync(at => at.Name.ToLower() == request.Name.ToLower() && at.Id != entity.Id))
                throw new UserException("Equipment with this name already exists.");
        }

        protected override void MapUpdateToEntity(Equipment entity, EquipmentUpsertRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
            base.MapUpdateToEntity(entity, request);
        }

        protected override async Task BeforeDelete(Equipment entity)
        {
            var relatedActivityEquipments = await _context.ActivityEquipments
                .Where(a => a.EquipmentId == entity.Id)
                .ToListAsync();

            if (relatedActivityEquipments.Any())
            {
                _context.ActivityEquipments.RemoveRange(relatedActivityEquipments);
            }
        }

        public async Task<EquipmentResponse?> MakeGlobalAsync(int id)
        {
            var entity = await _context.Equipments.FindAsync(id);
            if (entity == null)
                return null;

            entity.IsGlobal = true;
            entity.CreatedByTroopId = null; // Remove troop association when making global
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<EquipmentResponse>(entity);
        }
    }
}
