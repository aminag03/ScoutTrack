using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponse> LoginAsync(LoginRequest request);
        Task<LoginResponse> RefreshTokenAsync(string refreshToken);
        Task LogoutAsync(int userId);
        string GetUserRole(ClaimsPrincipal user);
        int? GetUserId(ClaimsPrincipal user);
        bool IsInRole(ClaimsPrincipal user, string role);
        Task<CurrentUserResponse?> GetCurrentUserAsync(ClaimsPrincipal user);

    }
} 