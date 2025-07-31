using Mapster;
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
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class ActivityEquipmentService : BaseCRUDService<ActivityEquipmentResponse, ActivityEquipmentSearchObject, ActivityEquipment, ActivityEquipmentUpsertRequest, ActivityEquipmentUpsertRequest>, IActivityEquipmentService
    {
        private readonly ScoutTrackDbContext _context;

        public ActivityEquipmentService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public async Task<List<ActivityEquipmentResponse>> GetByActivityIdAsync(int activityId)
        {
            var items = await _context.ActivityEquipments
                .Include(ae => ae.Equipment)
                .Where(ae => ae.ActivityId == activityId)
                .ToListAsync();

            return items.Adapt<List<ActivityEquipmentResponse>>();
        }

        public async Task<bool> RemoveByActivityIdAndEquipmentIdAsync(int activityId, int equipmentId)
        {
            var entity = await _context.ActivityEquipments
                .FirstOrDefaultAsync(ae => ae.ActivityId == activityId && ae.EquipmentId == equipmentId);

            if (entity == null)
                return false;

            _context.ActivityEquipments.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
} 