using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IMemberService : ICRUDService<MemberResponse, MemberSearchObject, MemberInsertRequest, MemberUpdateRequest>
    {
        Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request);
        Task<MemberResponse?> UpdateProfilePictureAsync(int id, string profilePictureUrl);
    }
} 