using System.Security.Claims;
using System.Threading.Tasks;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface ICommentService : ICRUDService<CommentResponse, CommentSearchObject, CommentUpsertRequest, CommentUpsertRequest>
    {
        Task<PagedResult<CommentResponse>> GetByPostAsync(int postId, CommentSearchObject search);
        Task<CommentResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id);
        Task<CommentResponse> CreateForUserAsync(CommentUpsertRequest request, ClaimsPrincipal user);
    }
}
