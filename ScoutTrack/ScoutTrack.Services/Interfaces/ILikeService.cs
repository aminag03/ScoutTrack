using System.Security.Claims;
using System.Threading.Tasks;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface ILikeService : IService<LikeResponse, LikeSearchObject>
    {
        Task<PagedResult<LikeResponse>> GetByPostAsync(int postId, LikeSearchObject search);
        Task<LikeResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id);
        Task<LikeResponse> LikePostAsync(int postId, int memberId);
        Task<bool> UnlikePostAsync(int postId, int memberId);
    }
}
