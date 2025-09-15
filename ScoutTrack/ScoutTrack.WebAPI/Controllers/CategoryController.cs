using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CategoryController : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        public CategoryController(ICategoryService categoryService) : base(categoryService)
        {
        }
    }
}
