using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IMemberBadgeService : ICRUDService<MemberBadgeResponse, MemberBadgeSearchObject, MemberBadgeUpsertRequest, MemberBadgeUpsertRequest>
    {
        Task<List<MemberBadgeResponse>> GetMembersByBadgeStatusAsync(int badgeId, ScoutTrack.Common.Enums.MemberBadgeStatus status);
        Task<List<MemberBadgeResponse>> GetMembersByBadgeStatusAndTroopAsync(int badgeId, ScoutTrack.Common.Enums.MemberBadgeStatus status, int troopId);
        Task<bool> CompleteMemberBadgeAsync(int memberBadgeId);
        Task<bool> UpdateMemberBadgeStatusAsync(int memberBadgeId, ScoutTrack.Common.Enums.MemberBadgeStatus newStatus);
        Task SyncProgressRecordsForBadge(int badgeId);
        Task SyncProgressRecordsForBadgeAndTroop(int badgeId, int troopId);
    }
}
