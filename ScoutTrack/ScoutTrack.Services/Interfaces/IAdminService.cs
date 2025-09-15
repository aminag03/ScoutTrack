using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IAdminService : ICRUDService<AdminResponse, AdminSearchObject, AdminInsertRequest, AdminUpdateRequest>
    {
        Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request);
        Task<AdminDashboardResponse?> GetDashboardAsync(int? year = null, int? timePeriodDays = null);
    }
} 