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
    }
} 