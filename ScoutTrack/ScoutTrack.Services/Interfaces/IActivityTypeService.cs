using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface IActivityTypeService : ICRUDService<ActivityTypeResponse, ActivityTypeSearchObject, ActivityTypeUpsertRequest, ActivityTypeUpsertRequest>
    {
    }
} 