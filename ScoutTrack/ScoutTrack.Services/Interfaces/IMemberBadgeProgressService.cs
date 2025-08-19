using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IMemberBadgeProgressService : ICRUDService<MemberBadgeProgressResponse, MemberBadgeProgressSearchObject, MemberBadgeProgressUpsertRequest, MemberBadgeProgressUpsertRequest>
    {
        Task<List<MemberBadgeProgressResponse>> GetByMemberBadgeIdAsync(int memberBadgeId);
        Task<bool> UpdateProgressCompletionAsync(int memberBadgeProgressId, bool isCompleted);
    }
}
