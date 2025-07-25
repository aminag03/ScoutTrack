using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class TroopService : BaseCRUDService<TroopResponse, TroopSearchObject, Troop, TroopInsertRequest, TroopUpdateRequest>, ITroopService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<MemberService> _logger;
        private readonly IWebHostEnvironment _env;

        public TroopService(ScoutTrackDbContext context, IMapper mapper, ILogger<MemberService> logger, IWebHostEnvironment env) : base(context, mapper) 
        {
            _context = context;
            _logger = logger;
            _env = env;
        }

        public override async Task<PagedResult<TroopResponse>> GetAsync(TroopSearchObject search)
        {
            var query = _context.Set<Troop>().AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            var entities = await query.ToListAsync();

            var responseList = entities.Select(MapToResponse).ToList();

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

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;

                if (orderBy.Equals("memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderBy(x => x.MemberCount).ToList();
                }
                else if (orderBy.Equals("-memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderByDescending(x => x.MemberCount).ToList();
                }
                else
                {
                    bool descending = false;
                    if (orderBy.StartsWith("-"))
                    {
                        descending = true;
                        orderBy = orderBy[1..];
                    }

                    responseList = orderBy.ToLower() switch
                    {
                        "name" => descending
                            ? responseList.OrderByDescending(x => x.Name).ToList()
                            : responseList.OrderBy(x => x.Name).ToList(),

                        "email" => descending
                            ? responseList.OrderByDescending(x => x.Email).ToList()
                            : responseList.OrderBy(x => x.Email).ToList(),

                        "username" => descending
                            ? responseList.OrderByDescending(x => x.Username).ToList()
                            : responseList.OrderBy(x => x.Username).ToList(),

                        _ => responseList
                    };
                }
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    responseList = responseList
                        .Skip(search.Page.Value * search.PageSize.Value)
                        .Take(search.PageSize.Value)
                        .ToList();
                }
            }

            return new PagedResult<TroopResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        public override async Task<TroopResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Troops
                .Include(t => t.City)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override IQueryable<Troop> ApplyFilter(IQueryable<Troop> query, TroopSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(t => t.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(t => t.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(t => t.Name.Contains(search.Name));
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(t => t.CityId == search.CityId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(t => t.Username.Contains(search.FTS) || 
                                        t.Email.Contains(search.FTS) || 
                                        t.Name.Contains(search.FTS));
            }

            query = query.Include(t => t.City);

            return query;
        }

        protected override async Task BeforeInsert(Troop entity, TroopInsertRequest request)
        {
            entity.Role = Role.Troop;
            
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email))
                throw new UserException("User with this email already exists.");

            if (await _context.Troops.AnyAsync(t => t.Name == request.Name))
                throw new UserException("Troop with this name already exists.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        protected override async Task BeforeUpdate(Troop entity, TroopUpdateRequest request)
        {
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username && ua.Id != entity.Id))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email && ua.Id != entity.Id))
                throw new UserException("User with this email already exists.");

            if (await _context.Troops.AnyAsync(t => t.Name == request.Name && t.Id != entity.Id))
                throw new UserException("Troop with this name already exists.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");
        }

        protected override void MapUpdateToEntity(Troop entity, TroopUpdateRequest request)
        {
            entity.UpdatedAt = DateTime.UtcNow;
            base.MapUpdateToEntity(entity, request);
        }

        public async Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request)
        {
            var entity = await _context.Troops.FindAsync(id);
            if (entity == null)
                return null;

            if (!BCrypt.Net.BCrypt.Verify(request.OldPassword, entity.PasswordHash))
                throw new UserException("Old password is not valid.");

            if (BCrypt.Net.BCrypt.Verify(request.NewPassword, entity.PasswordHash))
                throw new UserException("New password cannot be same as old password.");

            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
                throw new UserException("New password must have at least 8 characters.");

            if (request.NewPassword != request.ConfirmNewPassword)
                throw new UserException("New password and confirmation do not match.");

            if (!Regex.IsMatch(request.NewPassword, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"))
                throw new UserException("Password must contain at least one uppercase letter, one " +
                    "lowercase letter, one number and one special character.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        protected override async Task BeforeDelete(Troop entity)
        {
            var hasMembers = await _context.Members.AnyAsync(m => m.TroopId == entity.Id);
            if (hasMembers)
                throw new UserException("Cannot delete troop: it is referenced by one or more entities.");
        }

        public async Task<TroopResponse?> DeActivateAsync(int id)
        {
            var troop = await _context.Set<Troop>().FindAsync(id);
            if (troop == null)
                return null;

            if (!troop.IsActive)
                troop.IsActive = true;
            else
                troop.IsActive = false;

            await _context.SaveChangesAsync();
            return MapToResponse(troop);
        }

        public async Task<TroopResponse?> UpdateLogoAsync(int id, string? logoUrl)
        {
            var entity = await _context.Troops.FindAsync(id);
            if (entity == null)
                return null;

            if (!string.IsNullOrWhiteSpace(entity.LogoUrl))
            {
                try
                {
                    var oldUri = new Uri(entity.LogoUrl);
                    var relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting old logo image");
                }
            }

            entity.LogoUrl = string.IsNullOrWhiteSpace(logoUrl) ? "" : logoUrl;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<TroopResponse>(entity);
        }


        protected override TroopResponse MapToResponse(Troop entity)
        {
            return new TroopResponse
            {
                Id = entity.Id,
                Username = entity.Username,
                Email = entity.Email,
                Name = entity.Name,
                CityId = entity.CityId,
                CityName = entity.City?.Name ?? string.Empty,
                Latitude = entity.Latitude,
                Longitude = entity.Longitude,
                ContactPhone = entity.ContactPhone,
                LogoUrl = entity.LogoUrl,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                LastLoginAt = entity.LastLoginAt,
                MemberCount = _context.Members.Count(m => m.TroopId == entity.Id)
            };
        }
    }
} 