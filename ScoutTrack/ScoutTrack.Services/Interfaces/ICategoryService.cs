using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;

namespace ScoutTrack.Services.Interfaces
{
    public interface ICategoryService : ICRUDService<CategoryResponse, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
    }
}
