using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface ITroopService : ICRUDService<TroopResponse, TroopSearchObject, TroopInsertRequest, TroopUpdateRequest>
    {
        Task<TroopResponse?> DeActivateAsync(int id);
        Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request);
        Task<TroopResponse?> UpdateLogoAsync(int id, string logoUrl);
    }
} 