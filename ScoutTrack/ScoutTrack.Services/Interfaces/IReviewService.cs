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
    public interface IReviewService : ICRUDService<ReviewResponse, ReviewSearchObject, ReviewUpsertRequest, ReviewUpsertRequest>
    {
        Task<PagedResult<ReviewResponse>> GetByActivityAsync(int activityId, ReviewSearchObject search);
        Task<ReviewResponse?> GetByActivityAndMemberAsync(int activityId, int memberId);
        Task<bool> CanMemberReviewActivityAsync(int activityId, int memberId);
        Task<ReviewResponse> CreateForMemberAsync(ClaimsPrincipal user, ReviewUpsertRequest request);
        Task<ReviewResponse?> UpdateForMemberAsync(ClaimsPrincipal user, int id, ReviewUpsertRequest request);
        Task<bool> DeleteForMemberAsync(ClaimsPrincipal user, int id);
    }
}
