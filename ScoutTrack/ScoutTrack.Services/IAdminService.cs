using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public interface IAdminService : ICRUDService<AdminResponse, AdminSearchObject, AdminUpsertRequest, AdminUpsertRequest>
    {
    }
} 