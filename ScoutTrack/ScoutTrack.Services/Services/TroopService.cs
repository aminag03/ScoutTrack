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
                        "scoutmaster" => descending
                            ? responseList.OrderByDescending(x => x.ScoutMaster).ToList()
                            : responseList.OrderBy(x => x.ScoutMaster).ToList(),
                        "troopleader" => descending
                            ? responseList.OrderByDescending(x => x.TroopLeader).ToList()
                            : responseList.OrderBy(x => x.TroopLeader).ToList(),
                        "foundingdate" => descending
                            ? responseList.OrderByDescending(x => x.FoundingDate).ToList()
                            : responseList.OrderBy(x => x.FoundingDate).ToList(),

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

            if (search.FoundingDateFrom.HasValue)
            {
                query = query.Where(t => t.FoundingDate >= search.FoundingDateFrom.Value);
            }

            if (search.FoundingDateTo.HasValue)
            {
                query = query.Where(t => t.FoundingDate <= search.FoundingDateTo.Value);
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

            if (request.FoundingDate > DateTime.Now)
                throw new UserException("Founding date cannot be in the future.");

            if (request.FoundingDate < new DateTime(1907, 1, 1))
                throw new UserException("Founding date cannot be before 1907.");

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Password and confirmation do not match.");

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

            if (request.FoundingDate.HasValue)
            {
                if (request.FoundingDate.Value > DateTime.Now)
                    throw new UserException("Founding date cannot be in the future");

                if (request.FoundingDate.Value < new DateTime(1900, 1, 1))
                    throw new UserException("Founding date must be after 1900");
            }
        }

        protected override void MapUpdateToEntity(Troop entity, TroopUpdateRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
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
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool?> AdminChangePasswordAsync(int id, AdminChangePasswordRequest request)
        {
            var entity = await _context.Troops.FindAsync(id);
            if (entity == null)
                return null;

            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
                throw new UserException("New password must have at least 8 characters.");

            if (request.NewPassword != request.ConfirmNewPassword)
                throw new UserException("New password and confirmation do not match.");

            if (!Regex.IsMatch(request.NewPassword, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"))
                throw new UserException("Password must contain at least one uppercase letter, one " +
                    "lowercase letter, one number and one special character.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        protected override async Task BeforeDelete(Troop entity)
        {
            var hasMembers = await _context.Members.AnyAsync(m => m.TroopId == entity.Id);
            if (hasMembers)
                throw new UserException("Cannot delete troop: it is referenced by one or more entities.");

            if (!string.IsNullOrWhiteSpace(entity.LogoUrl))
            {
                try
                {
                    string relativePath;
                    if (entity.LogoUrl.StartsWith("http"))
                    {
                        var uri = new Uri(entity.LogoUrl);
                        relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.LogoUrl.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting troop logo image from file system.");
                }
            }
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
                    string relativePath;
                    if (entity.LogoUrl.StartsWith("http"))
                    {
                        var oldUri = new Uri(entity.LogoUrl);
                        relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.LogoUrl.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
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

        public async Task<TroopDashboardResponse?> GetDashboardAsync(int troopId, int? year = null, int? timePeriodDays = null)
        {
            var troop = await _context.Troops.FindAsync(troopId);
            if (troop == null)
                return null;

            var now = DateTime.Now;
            var currentYear = year ?? now.Year;
            var timePeriod = timePeriodDays ?? 30;

            var memberCount = await _context.Members.CountAsync(m => m.TroopId == troopId && m.IsActive);

            var pendingRegistrationCount = await _context.ActivityRegistrations
                .Where(ar => ar.Activity.TroopId == troopId && ar.Status == RegistrationStatus.Pending)
                .CountAsync();

            var activityCount = await _context.Activities.CountAsync(a => a.TroopId == troopId);

            var upcomingActivities = await _context.Activities
                .Where(a => a.TroopId == troopId && 
                           a.StartTime > now && 
                           a.ActivityState != "FinishedActivityState" && 
                           a.ActivityState != "CancelledActivityState")
                .OrderBy(a => a.StartTime)
                .Take(3)
                .Select(a => new UpcomingActivityResponse
                {
                    Id = a.Id,
                    Title = a.Title,
                    StartTime = a.StartTime.Value,
                    EndTime = a.EndTime.Value,
                    LocationName = a.LocationName,
                    ActivityTypeName = a.ActivityType.Name,
                    Fee = a.Fee ?? 0,
                    ImagePath = a.ImagePath
                })
                .ToListAsync();

            var timePeriodStart = now.AddDays(-timePeriod);
            var mostActiveMembers = await _context.Members
                .Where(m => m.TroopId == troopId && m.IsActive)
                .Select(m => new
                {
                    Member = m,
                    ActivityCount = _context.ActivityRegistrations
                        .Where(ar => ar.MemberId == m.Id && 
                                   ar.Status == RegistrationStatus.Completed &&
                                   ar.RegisteredAt >= timePeriodStart)
                        .Count(),
                    PostCount = _context.Posts
                        .Where(p => p.CreatedById == m.Id && 
                                  p.CreatedAt >= timePeriodStart)
                        .Count()
                })
                .OrderByDescending(x => x.ActivityCount)
                .ThenByDescending(x => x.PostCount)
                .Take(3)
                .Select(x => new MostActiveMemberResponse
                {
                    Id = x.Member.Id,
                    FirstName = x.Member.FirstName,
                    LastName = x.Member.LastName,
                    ActivityCount = x.ActivityCount,
                    PostCount = x.PostCount,
                    ProfilePictureUrl = x.Member.ProfilePictureUrl
                })
                .ToListAsync();

            var monthlyAttendance = new List<MonthlyAttendanceResponse>();
            var monthNames = new[] { "Januar", "Februar", "Mart", "April", "Maj", "Juni",
                                   "Juli", "August", "Septembar", "Oktobar", "Novembar", "Decembar" };

            for (int month = 1; month <= 12; month++)
            {
                var monthStart = new DateTime(currentYear, month, 1);
                var monthEnd = monthStart.AddMonths(1).AddDays(-1);

                var finishedActivitiesInMonth = await _context.Activities
                    .Where(a => a.TroopId == troopId && 
                               a.ActivityState == "FinishedActivityState" &&
                               a.EndTime >= monthStart && 
                               a.EndTime <= monthEnd)
                    .ToListAsync();

                var averageAttendance = 0.0;
                if (finishedActivitiesInMonth.Any())
                {
                    var totalRegistrations = finishedActivitiesInMonth.Sum(a => 
                        _context.ActivityRegistrations.Count(ar => ar.ActivityId == a.Id && ar.Status == RegistrationStatus.Completed));
                    averageAttendance = (double)totalRegistrations / finishedActivitiesInMonth.Count;
                }

                monthlyAttendance.Add(new MonthlyAttendanceResponse
                {
                    Month = month,
                    MonthName = monthNames[month - 1],
                    AverageAttendance = averageAttendance,
                    Year = currentYear
                });
            }

            var firstActivityYearQuery = await _context.Activities
                .Where(a => a.TroopId == troopId)
                .Select(a => a.CreatedAt.Year)
                .ToListAsync();

            var firstActivityYear = firstActivityYearQuery.Any() 
                ? firstActivityYearQuery.Min() 
                : currentYear;

            var availableYears = Enumerable.Range(firstActivityYear, currentYear - firstActivityYear + 1)
                .OrderByDescending(y => y)
                .ToList();

            return new TroopDashboardResponse
            {
                MemberCount = memberCount,
                PendingRegistrationCount = pendingRegistrationCount,
                ActivityCount = activityCount,
                UpcomingActivities = upcomingActivities,
                MostActiveMembers = mostActiveMembers,
                MonthlyAttendance = monthlyAttendance,
                AvailableYears = availableYears
            };
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
                ScoutMaster = entity.ScoutMaster,
                TroopLeader = entity.TroopLeader,
                FoundingDate = entity.FoundingDate,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                LastLoginAt = entity.LastLoginAt,
                MemberCount = _context.Members.Count(m => m.TroopId == entity.Id)
            };
        }
    }
} 