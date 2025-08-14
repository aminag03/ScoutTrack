using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Hosting;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class BadgeService : BaseCRUDService<BadgeResponse, BadgeSearchObject, Badge, BadgeUpsertRequest, BadgeUpsertRequest>, IBadgeService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<BadgeService> _logger;
        private readonly IWebHostEnvironment _env;

        public BadgeService(ScoutTrackDbContext context, IMapper mapper, ILogger<BadgeService> logger, IWebHostEnvironment env) : base(context, mapper) 
        {
            _context = context;
            _logger = logger;
            _env = env;
        }

        protected override IQueryable<Badge> ApplyFilter(IQueryable<Badge> query, BadgeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(pt => pt.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(pt => pt.Name.Contains(search.FTS) || pt.Description.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(Badge entity, BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name))
                throw new UserException("Badge with this name already exists.");
        }

        protected override async Task BeforeUpdate(Badge entity, BadgeUpsertRequest request)
        {
            if (await _context.Badges.AnyAsync(b => b.Name == request.Name && b.Id != entity.Id))
                throw new UserException("Badge with this name already exists.");

            // Delete old image if it's different from the new one
            if (!string.IsNullOrEmpty(entity.ImageUrl) && entity.ImageUrl != request.ImageUrl)
            {
                DeleteImageFile(entity.ImageUrl);
            }
        }

        protected override async Task BeforeDelete(Badge entity)
        {
            if (!string.IsNullOrEmpty(entity.ImageUrl))
            {
                DeleteImageFile(entity.ImageUrl);
            }
        }

        private void DeleteImageFile(string imageUrl)
        {
            if (string.IsNullOrWhiteSpace(imageUrl))
                return;

            try
            {
                var uri = new Uri(imageUrl);
                var relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                    _logger.LogInformation($"Deleted badge image file: {fullPath}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error while deleting badge image file: {imageUrl}", imageUrl);
            }
        }
    }
}