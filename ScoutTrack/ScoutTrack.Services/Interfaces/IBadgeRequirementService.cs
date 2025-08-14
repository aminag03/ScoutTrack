using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IBadgeRequirementService : ICRUDService<BadgeRequirementResponse, BadgeRequirementSearchObject, BadgeRequirementUpsertRequest, BadgeRequirementUpsertRequest>
    {
    }
}
