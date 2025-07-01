using System.Threading.Tasks;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;

namespace ScoutTrack.Services.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponse> LoginAsync(LoginRequest request);
        Task<LoginResponse> RefreshTokenAsync(string refreshToken);
        Task LogoutAsync(int userId);
        string GetUserRole(System.Security.Claims.ClaimsPrincipal user);
        int? GetUserId(System.Security.Claims.ClaimsPrincipal user);
        bool IsInRole(System.Security.Claims.ClaimsPrincipal user, string role);
        Task<bool> CanTroopAccessMember(System.Security.Claims.ClaimsPrincipal user, int memberId);
    }
} 