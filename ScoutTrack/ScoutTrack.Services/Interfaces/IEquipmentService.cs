using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IEquipmentService : ICRUDService<EquipmentResponse, EquipmentSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        Task<EquipmentResponse> CreateWithAutoFieldsAsync(EquipmentUpsertRequest request, bool isGlobal, int? createdByTroopId);
        Task<EquipmentResponse?> MakeGlobalAsync(int id);
    }
}
