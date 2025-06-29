using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public interface ICityService
    {
        Task<IEnumerable<CityResponse>> GetAsync(CitySearchObject search);
        Task<CityResponse?> GetByIdAsync(int id);
        Task<CityResponse> CreateAsync(CityUpsertRequest city);
        Task<CityResponse?> UpdateAsync(int id, CityUpsertRequest city);
        Task<bool> DeleteAsync(int id);
    }
} 