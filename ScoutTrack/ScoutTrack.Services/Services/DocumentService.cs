using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services.ActivityStateMachine;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class DocumentService : BaseCRUDService<DocumentResponse, DocumentSearchObject, Document, DocumentUpsertRequest, DocumentUpsertRequest>, IDocumentService
    {
        private readonly ILogger<DocumentService> _logger;
        private readonly IWebHostEnvironment _env;

        public DocumentService(ScoutTrackDbContext context, IMapper mapper, ILogger<DocumentService> logger, IWebHostEnvironment env) : base(context, mapper)
        {
            _logger = logger;
            _env = env;
        }

        public override async Task<PagedResult<DocumentResponse>> GetAsync(DocumentSearchObject search)
        {
            var query = base._context.Set<Document>()
                .Include(d => d.Admin)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                if (search.OrderBy.StartsWith("-"))
                {
                    query = query.OrderByDescendingDynamic(search.OrderBy[1..]);
                }
                else
                {
                    query = query.OrderByDynamic(search.OrderBy);
                }
            }
            else
            {
                query = query.OrderByDescending(d => d.CreatedAt);
            }

            var entities = await query.ToListAsync();
            
            var hasChanges = false;
            foreach (var entity in entities)
            {
                var normalizedPath = NormalizeFilePath(entity.FilePath);
                if (normalizedPath != entity.FilePath)
                {
                    entity.FilePath = normalizedPath;
                    hasChanges = true;
                }
            }
            
            if (hasChanges)
            {
                await base._context.SaveChangesAsync();
            }
            
            var responseList = entities.Select(MapToResponse).ToList();

            return new PagedResult<DocumentResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Document> ApplyFilter(IQueryable<Document> query, DocumentSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(d => d.Title.Contains(search.Title));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(d => d.Title.Contains(search.FTS));
            }

            return query;
        }

        public override async Task<DocumentResponse> CreateAsync(DocumentUpsertRequest request)
        {
            throw new InvalidOperationException("Use CreateAsync(request, adminId) method instead.");
        }

        public async Task<DocumentResponse> CreateAsync(DocumentUpsertRequest request, int adminId)
        {
            if (adminId <= 0)
                throw new UserException("AdminId is required.");

            var document = new Document
            {
                Title = request.Title,
                AdminId = adminId,
                FilePath = NormalizeFilePath(request.FilePath),
                CreatedAt = DateTime.Now
            };

            await BeforeInsert(document, request);

            base._context.Documents.Add(document);
            await base._context.SaveChangesAsync();

            return await base.GetByIdAsync(document.Id);
        }

        protected override async Task BeforeInsert(Document entity, DocumentUpsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                throw new UserException("Document title is required.");
                
            if (request.Title.Length > 100)
                throw new UserException("Document title cannot exceed 100 characters.");

            if (await base._context.Documents.AnyAsync(d => d.Title == request.Title))
                throw new UserException("A document with this title already exists.");

            if (string.IsNullOrWhiteSpace(request.FilePath))
                throw new UserException("File path is required.");
        }

        protected override async Task BeforeUpdate(Document entity, DocumentUpsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                throw new UserException("Document title is required.");
                
            if (request.Title.Length > 100)
                throw new UserException("Document title cannot exceed 100 characters.");

            if (await base._context.Documents.AnyAsync(d => d.Title == request.Title && d.Id != entity.Id))
                throw new UserException("A document with this title already exists.");

            if (string.IsNullOrWhiteSpace(request.FilePath))
                throw new UserException("File path is required.");
        }

        private string NormalizeFilePath(string filePath)
        {
            if (filePath.Contains(Path.DirectorySeparatorChar) || filePath.Contains('/'))
            {
                return Path.GetFileName(filePath);
            }
            return filePath;
        }

        protected override void MapUpdateToEntity(Document entity, DocumentUpsertRequest request)
        {
            var normalizedOldPath = NormalizeFilePath(entity.FilePath);
            var normalizedNewPath = NormalizeFilePath(request.FilePath);
            
            if (normalizedOldPath != normalizedNewPath && !string.IsNullOrEmpty(normalizedOldPath))
            {
                try
                {
                    var oldFilePath = Path.Combine(_env.WebRootPath, "documents", normalizedOldPath);
                    if (!File.Exists(oldFilePath) && !string.IsNullOrEmpty(entity.FilePath))
                    {
                        oldFilePath = Path.Combine(_env.WebRootPath, "documents", entity.FilePath);
                    }
                    
                    if (File.Exists(oldFilePath))
                    {
                        File.Delete(oldFilePath);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting old document file: {OldFilePath}", entity.FilePath);
                }
            }

            entity.Title = request.Title;
            entity.FilePath = normalizedNewPath;
            entity.UpdatedAt = DateTime.Now;
        }

        protected override DocumentResponse MapToResponse(Document entity)
        {
            return new DocumentResponse
            {
                Id = entity.Id,
                Title = entity.Title,
                FilePath = entity.FilePath,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                AdminId = entity.AdminId,
                AdminFullName = entity.Admin?.FullName ?? string.Empty
            };
        }

        public async Task<byte[]> DownloadDocumentAsync(int id)
        {
            var document = await base._context.Documents.FindAsync(id);
            if (document == null)
                throw new UserException("Document not found.");

            var normalizedPath = NormalizeFilePath(document.FilePath);
            var filePath = Path.Combine(_env.WebRootPath, "documents", normalizedPath);
            
            if (!File.Exists(filePath) && !string.IsNullOrEmpty(document.FilePath))
            {
                filePath = Path.Combine(_env.WebRootPath, "documents", document.FilePath);
            }
            
            if (!File.Exists(filePath))
                throw new UserException("Document file not found.");

            return await File.ReadAllBytesAsync(filePath);
        }

        public async Task<string> UploadDocumentAsync(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new UserException("No file provided.");

            var allowedExtensions = new[] { ".pdf", ".doc", ".docx", ".txt", ".jpg", ".jpeg", ".png" };
            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(fileExtension))
                throw new UserException("Invalid file type. Allowed types: PDF, DOC, DOCX, TXT, JPG, JPEG, PNG");

            if (file.Length > 10 * 1024 * 1024)
                throw new UserException("File size too large. Maximum size is 10MB.");

            var documentsPath = Path.Combine(_env.WebRootPath, "documents");
            if (!Directory.Exists(documentsPath))
                Directory.CreateDirectory(documentsPath);

            var fileName = $"{Guid.NewGuid()}{fileExtension}";
            var filePath = Path.Combine(documentsPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return fileName;
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var document = await base._context.Documents.FindAsync(id);
            if (document == null)
                return false;

            var normalizedPath = NormalizeFilePath(document.FilePath);
            var filePath = Path.Combine(_env.WebRootPath, "documents", normalizedPath);
            
            if (!File.Exists(filePath) && !string.IsNullOrEmpty(document.FilePath))
            {
                filePath = Path.Combine(_env.WebRootPath, "documents", document.FilePath);
            }
            
            
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            base._context.Documents.Remove(document);
            await base._context.SaveChangesAsync();
            
            return true;
        }

        public async Task<bool> DocumentFileExistsAsync(int id)
        {
            var document = await base._context.Documents.FindAsync(id);
            if (document == null)
                return false;

            var normalizedPath = NormalizeFilePath(document.FilePath);
            var filePath = Path.Combine(_env.WebRootPath, "documents", normalizedPath);
            
            if (!File.Exists(filePath) && !string.IsNullOrEmpty(document.FilePath))
            {
                filePath = Path.Combine(_env.WebRootPath, "documents", document.FilePath);
            }
            
            return File.Exists(filePath);
        }
    }
}
