using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Interfaces;
using System.Security.Claims;

namespace ScoutTrack.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class DocumentController : BaseController<DocumentResponse, DocumentSearchObject>
    {
        private readonly IDocumentService _documentService;

        public DocumentController(IDocumentService documentService) : base(documentService)
        {
            _documentService = documentService;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<DocumentResponse>> Create([FromBody] DocumentUpsertRequest request)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                
                if (userId == 0)
                    return Unauthorized("Invalid user.");

                var response = await _documentService.CreateAsync(request, userId);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<DocumentResponse>> Update(int id, [FromBody] DocumentUpsertRequest request)
        {
            try
            {
                var response = await _documentService.UpdateAsync(id, request);
                if (response == null)
                    return NotFound("Document not found.");

                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                var result = await _documentService.DeleteAsync(id);
                if (!result)
                    return NotFound("Document not found.");

                return Ok("Document deleted successfully.");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("download/{id}")]
        public async Task<IActionResult> Download(int id)
        {
            try
            {
                var fileBytes = await _documentService.DownloadDocumentAsync(id);
                var document = await _documentService.GetByIdAsync(id);
                
                if (document == null)
                    return NotFound("Document not found.");

                var fileName = $"{document.Title}{Path.GetExtension(document.FilePath)}";
                var contentType = GetContentType(document.FilePath);

                return File(fileBytes, contentType, fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("upload")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<string>> Upload(IFormFile file)
        {
            try
            {
                var fileName = await _documentService.UploadDocumentAsync(file);
                return Ok(fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("migrate-file-paths")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<string>> MigrateFilePaths()
        {
            try
            {
                var result = await _documentService.GetAsync(new DocumentSearchObject { Page = 0, PageSize = 1 });
                return Ok("File path migration completed successfully.");
            }
            catch (Exception ex)
            {
                return BadRequest($"Migration failed: {ex.Message}");
            }
        }

        [HttpGet("{id}/file-exists")]
        public async Task<ActionResult<bool>> DocumentFileExists(int id)
        {
            try
            {
                var exists = await _documentService.DocumentFileExistsAsync(id);
                return Ok(exists);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error checking file existence: {ex.Message}");
            }
        }

        private string GetContentType(string filePath)
        {
            var extension = Path.GetExtension(filePath).ToLowerInvariant();
            return extension switch
            {
                ".pdf" => "application/pdf",
                ".doc" => "application/msword",
                ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                ".txt" => "text/plain",
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => "application/octet-stream"
            };
        }
    }
}
