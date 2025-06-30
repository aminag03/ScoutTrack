using System.Threading.Tasks;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;

namespace ScoutTrack.Services
{
    public interface IAuthService
    {
        Task<LoginResponse> LoginAsync(LoginRequest request);
        Task<LoginResponse> RefreshTokenAsync(string refreshToken);
        Task LogoutAsync(int userId);
    }
} 