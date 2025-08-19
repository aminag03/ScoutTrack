using Microsoft.AspNetCore.Http;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Interfaces
{
    public interface IDocumentService : ICRUDService<DocumentResponse, DocumentSearchObject, DocumentUpsertRequest, DocumentUpsertRequest>
    {
        Task<DocumentResponse> CreateAsync(DocumentUpsertRequest request, int adminId);
        Task<byte[]> DownloadDocumentAsync(int id);
        Task<string> UploadDocumentAsync(IFormFile file);
        Task<bool> DocumentFileExistsAsync(int id);
    }
}
