using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public interface IBadgeService
    {
        Task<IEnumerable<BadgeResponse>> GetAsync(BadgeSearchObject search);
        Task<BadgeResponse?> GetByIdAsync(int id);
        Task<BadgeResponse> CreateAsync(BadgeUpsertRequest badge);
        Task<BadgeResponse?> UpdateAsync(int id, BadgeUpsertRequest badge);
        Task<bool> DeleteAsync(int id);
    }
}
