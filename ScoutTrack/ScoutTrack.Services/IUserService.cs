using ScoutTrack.Model;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Model.Responses;
using System.Threading.Tasks;
using System.Collections.Generic;
using ScoutTrack.Model.Requests;

namespace ScoutTrack.Services
{
    public interface IUserService
    {
        Task<IEnumerable<UserResponse>> GetAsync(UserSearchObject search);
        Task<UserResponse?> GetByIdAsync(int id);
        Task<UserResponse> CreateAsync(UserUpsertRequest user);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest user);
        Task<bool> DeleteAsync(int id);
    }
}