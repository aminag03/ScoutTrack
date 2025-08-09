using System.Security.Claims;
using System.Threading.Tasks;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface IPostService : ICRUDService<PostResponse, PostSearchObject, PostUpsertRequest, PostUpsertRequest>
    {
        Task<PostResponse> CreateAsync(PostUpsertRequest request, ClaimsPrincipal user);
        Task<PagedResult<PostResponse>> GetByActivityAsync(int activityId, PostSearchObject search);
        Task<PostResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id);
        Task<PostResponse> LikePostAsync(int postId, int userId);
        Task<PostResponse> UnlikePostAsync(int postId, int userId);
    }
}
