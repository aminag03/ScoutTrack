using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Security.Claims;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IActivityRegistrationService : ICRUDService<ActivityRegistrationResponse, ActivityRegistrationSearchObject, ActivityRegistrationUpsertRequest, ActivityRegistrationUpsertRequest>
    {
        Task<ActivityRegistrationResponse> ApproveAsync(int id);
        Task<ActivityRegistrationResponse> RejectAsync(int id);
        Task<bool> CancelAsync(int id);
        Task<ActivityRegistrationResponse> CompleteAsync(int id);
        Task<PagedResult<ActivityRegistrationResponse>> GetForUserAsync(ClaimsPrincipal user, ActivityRegistrationSearchObject search);
        Task<ActivityRegistrationResponse> CreateForUserAsync(ClaimsPrincipal user, ActivityRegistrationUpsertRequest request);
        Task<ActivityRegistrationResponse> ApproveForUserAsync(ClaimsPrincipal user, int id);
        Task<ActivityRegistrationResponse> RejectForUserAsync(ClaimsPrincipal user, int id);
        Task<bool> CancelForUserAsync(ClaimsPrincipal user, int id);
        Task<ActivityRegistrationResponse> CompleteForUserAsync(ClaimsPrincipal user, int id);
        Task<ActivityRegistrationResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id);
        Task<ActivityRegistrationResponse> UpdateForUserAsync(ClaimsPrincipal user, int id, ActivityRegistrationUpsertRequest request);
        Task<bool> DeleteForUserAsync(ClaimsPrincipal user, int id);
    }
} 