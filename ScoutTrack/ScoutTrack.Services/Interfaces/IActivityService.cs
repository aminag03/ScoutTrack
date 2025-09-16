using System.Security.Claims;
using System.Threading.Tasks;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface IActivityService : ICRUDService<ActivityResponse, ActivitySearchObject, ActivityUpsertRequest, ActivityUpsertRequest>
    {
        Task<ActivityResponse> ActivateAsync(int id);
        Task<ActivityResponse> DeactivateAsync(int id);
        Task<ActivityResponse> CloseRegistrationsAsync(int id);
        Task<ActivityResponse> FinishAsync(int id);
        Task<ActivityResponse?> UpdateImageAsync(int id, string? imagePath);
        Task<ActivityResponse?> UpdateSummaryAsync(int id, string summary);
        Task<ActivityResponse?> TogglePrivacyAsync(int id);
        Task<ActivityResponse?> ReactivateAsync(int id);
        Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request);
        Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request, int currentUserId);
        Task<PagedResult<ActivityResponse>> GetForUserAsync(ClaimsPrincipal user, ActivitySearchObject search);
        Task<ActivityResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id);
    }
} 