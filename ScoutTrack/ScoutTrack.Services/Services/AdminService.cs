using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class AdminService : BaseCRUDService<AdminResponse, AdminSearchObject, Admin, AdminInsertRequest, AdminUpdateRequest>, IAdminService
    {
        private readonly ScoutTrackDbContext _context;

        public AdminService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper) 
        {
            _context = context;
        }

        protected override IQueryable<Admin> ApplyFilter(IQueryable<Admin> query, AdminSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(a => a.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(a => a.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.FullName))
            {
                query = query.Where(a => a.FullName.Contains(search.FullName));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => a.Username.Contains(search.FTS) || 
                                        a.Email.Contains(search.FTS) || 
                                        a.FullName.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(Admin entity, AdminInsertRequest request)
        {
            entity.Role = Role.Admin;
            
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email))
                throw new UserException("User with this email already exists.");

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Password and confirmation do not match.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        }

        protected override async Task BeforeUpdate(Admin entity, AdminUpdateRequest request)
        {
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username && ua.Id != entity.Id))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email && ua.Id != entity.Id))
                throw new UserException("User with this email already exists.");
        }

        protected override void MapUpdateToEntity(Admin entity, AdminUpdateRequest request)
        {
            entity.UpdatedAt = DateTime.Now;
            base.MapUpdateToEntity(entity, request);
        }

        public async Task<bool?> ChangePasswordAsync(int id, ChangePasswordRequest request)
        {
            var entity = await _context.Admins.FindAsync(id);
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

        public async Task<AdminDashboardResponse?> GetDashboardAsync(int? year = null, int? timePeriodDays = null)
        {
            var now = DateTime.Now;
            var currentYear = year ?? now.Year;

            var troopCount = await _context.Troops.CountAsync();
            var memberCount = await _context.Members.CountAsync();
            var activityCount = await _context.Activities.CountAsync(a => a.ActivityState == "FinishedActivityState");
            var postCount = await _context.Posts.CountAsync();

            IQueryable<Troop> troopsQuery = _context.Troops;
            
            var mostActiveTroopsQuery = troopsQuery.Select(t => new
            {
                Troop = t,
                ActivityCount = timePeriodDays.HasValue
                    ? _context.Activities
                        .Where(a => a.TroopId == t.Id && 
                                   a.ActivityState == "FinishedActivityState" &&
                                   a.EndTime >= now.AddDays(-timePeriodDays.Value))
                        .Count()
                    : _context.Activities
                        .Where(a => a.TroopId == t.Id && 
                                   a.ActivityState == "FinishedActivityState")
                        .Count()
            });

            var mostActiveTroops = await mostActiveTroopsQuery
                .OrderByDescending(x => x.ActivityCount)
                .Take(3)
                .Select(x => new MostActiveTroopResponse
                {
                    Id = x.Troop.Id,
                    Name = x.Troop.Name,
                    ActivityCount = x.ActivityCount,
                    CityName = x.Troop.City.Name
                })
                .ToListAsync();

            var monthlyActivities = new List<MonthlyActivityResponse>();
            var monthNames = new[] { "Januar", "Februar", "Mart", "April", "Maj", "Juni",
                                   "Juli", "August", "Septembar", "Oktobar", "Novembar", "Decembar" };

            for (int month = 1; month <= 12; month++)
            {
                var monthStart = new DateTime(currentYear, month, 1);
                var monthEnd = monthStart.AddMonths(1).AddDays(-1);

                var activityCountInMonth = await _context.Activities
                    .Where(a => a.ActivityState == "FinishedActivityState" &&
                               a.EndTime >= monthStart && 
                               a.EndTime <= monthEnd)
                    .CountAsync();

                monthlyActivities.Add(new MonthlyActivityResponse
                {
                    Month = month,
                    MonthName = monthNames[month - 1],
                    ActivityCount = activityCountInMonth,
                    Year = currentYear
                });
            }

            var monthlyAttendance = new List<MonthlyAttendanceResponse>();

            for (int month = 1; month <= 12; month++)
            {
                var monthStart = new DateTime(currentYear, month, 1);
                var monthEnd = monthStart.AddMonths(1).AddDays(-1);

                var finishedActivitiesInMonth = await _context.Activities
                    .Where(a => a.ActivityState == "FinishedActivityState" &&
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

            var totalMembers = await _context.Members.CountAsync();
            var scoutCategoriesData = await _context.Categories
                .Select(c => new
                {
                    Category = c,
                    MemberCount = _context.Members.Count(m => m.CategoryId == c.Id)
                })
                .Where(x => x.MemberCount > 0)
                .ToListAsync();

            var scoutCategories = scoutCategoriesData.Select(x => new ScoutCategoryResponse
            {
                Id = x.Category.Id,
                Name = x.Category.Name,
                MemberCount = x.MemberCount,
                Percentage = totalMembers > 0 ? (double)x.MemberCount / totalMembers * 100 : 0,
                Color = string.Empty // Will be assigned on frontend
            }).ToList();

            var firstActivityYearQuery = await _context.Activities
                .Select(a => a.CreatedAt.Year)
                .ToListAsync();

            var firstActivityYear = firstActivityYearQuery.Any() 
                ? firstActivityYearQuery.Min() 
                : currentYear;

            var availableYears = Enumerable.Range(firstActivityYear, currentYear - firstActivityYear + 1)
                .OrderByDescending(y => y)
                .ToList();

            return new AdminDashboardResponse
            {
                TroopCount = troopCount,
                MemberCount = memberCount,
                ActivityCount = activityCount,
                PostCount = postCount,
                MostActiveTroops = mostActiveTroops,
                MonthlyActivities = monthlyActivities,
                MonthlyAttendance = monthlyAttendance,
                ScoutCategories = scoutCategories,
                AvailableYears = availableYears
            };
        }

    }
} 