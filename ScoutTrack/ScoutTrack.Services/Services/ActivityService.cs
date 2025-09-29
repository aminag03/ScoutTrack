using Azure;
using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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
    public class ActivityService : BaseCRUDService<ActivityResponse, ActivitySearchObject, Activity, ActivityUpsertRequest, ActivityUpsertRequest>, IActivityService
    {
        private readonly ScoutTrackDbContext _context;
        protected readonly BaseActivityState _baseActivityState;
        private readonly ILogger<MemberService> _logger;
        private readonly IWebHostEnvironment _env;
        private readonly IAccessControlService _accessControlService;

        public ActivityService(ScoutTrackDbContext context, IMapper mapper, BaseActivityState baseActivityState, ILogger<MemberService> logger, IWebHostEnvironment env, IAccessControlService accessControlService) : base(context, mapper)
        {
            _context = context;
            _baseActivityState = baseActivityState;
            _logger = logger;
            _env = env;
            _accessControlService = accessControlService;
        }

        public override async Task<PagedResult<ActivityResponse>> GetAsync(ActivitySearchObject search)
        {
            var query = _context.Set<Activity>().AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
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

            var entities = await query.ToListAsync();
            var responseList = entities.Select(MapToResponse).ToList();

            if (!string.IsNullOrWhiteSpace(search.OrderBy))
            {
                var orderBy = search.OrderBy;

                if (orderBy.Equals("memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderBy(x => x.RegistrationCount).ToList();
                }
                else if (orderBy.Equals("-memberCount", StringComparison.OrdinalIgnoreCase))
                {
                    responseList = responseList.OrderByDescending(x => x.RegistrationCount).ToList();
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
                        "title" => descending
                            ? responseList.OrderByDescending(x => x.Title).ToList()
                            : responseList.OrderBy(x => x.Title).ToList(),

                        "starttime" => descending
                            ? responseList.OrderByDescending(x => x.StartTime).ToList()
                            : responseList.OrderBy(x => x.StartTime).ToList(),

                        "endtime" => descending
                            ? responseList.OrderByDescending(x => x.EndTime).ToList()
                            : responseList.OrderBy(x => x.EndTime).ToList(),

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

            return new PagedResult<ActivityResponse>
            {
                Items = responseList,
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Activity> ApplyFilter(IQueryable<Activity> query, ActivitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(a => a.Title.Contains(search.Title));
            }
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a => a.Title.Contains(search.FTS) || a.Description.Contains(search.FTS));
            }
            if (search.TroopId.HasValue)
            {
                query = query.Where(a => a.TroopId == search.TroopId.Value);
            }
            if (search.ActivityTypeId.HasValue)
            {
                query = query.Where(a => a.ActivityTypeId == search.ActivityTypeId.Value);
            }
            if (search.IsPrivate.HasValue)
            {
                query = query.Where(a => a.isPrivate == search.IsPrivate.Value);
            }
            if (!string.IsNullOrEmpty(search.ActivityState))
            {
                query = query.Where(a => a.ActivityState == search.ActivityState);
            }
            if (search.ShowPublicAndOwn.HasValue && search.ShowPublicAndOwn.Value && search.OwnTroopId.HasValue)
            {
                query = query.Where(a => 
                    (!a.isPrivate || a.TroopId == search.OwnTroopId.Value) && 
                    ((a.ActivityState != "DraftActivityState" && a.ActivityState != "CancelledActivityState") || a.TroopId == search.OwnTroopId.Value));
            }

            query = query.Include(a => a.Troop);
            query = query.Include(a => a.ActivityType);

            return query;
        }

        public override async Task<ActivityResponse> CreateAsync(ActivityUpsertRequest request)
        {
            var baseState = _baseActivityState.GetActivityState(nameof(InitialActivityState));

            var entity = new Activity();
            _mapper.Map(request, entity);
            await BeforeInsert(entity, request);

            var result = await baseState.CreateAsync(request);
            return result;

            // return await base.CreateAsync(request);
        }

        public override async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpsertRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            _mapper.Map(request, entity);
            await BeforeUpdate(entity, request);

            return await baseState.UpdateAsync(id, request);
            // return await base.UpdateAsync(id, request);
        }

        public override async Task<ActivityResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Activities
                .Include(a => a.Troop)
                .Include(a => a.ActivityType)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");

            return await baseState.UpdateAsync(id, request);
        }

        public async Task<ActivityResponse?> UpdateAsync(int id, ActivityUpdateRequest request, int currentUserId)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");

            return await baseState.UpdateAsync(id, request, currentUserId);
        }

        protected override async Task BeforeInsert(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        protected override async Task BeforeUpdate(Activity entity, ActivityUpsertRequest request)
        {
            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.ActivityTypes.AnyAsync(at => at.Id == request.ActivityTypeId))
                throw new UserException($"ActivityType with ID {request.ActivityTypeId} does not exist.");
        }

        protected override async Task BeforeDelete(Activity entity)
        {
            var posts = await _context.Posts
                .Include(p => p.Images)
                .Include(p => p.Likes)
                .Include(p => p.Comments)
                .Where(p => p.ActivityId == entity.Id)
                .ToListAsync();
            
            if (posts.Any())
            {
                foreach (var post in posts)
                {
                    if (post.Likes.Any())
                    {
                        _context.Likes.RemoveRange(post.Likes);
                    }
                    
                    if (post.Comments.Any())
                    {
                        _context.Comments.RemoveRange(post.Comments);
                    }
                    
                    if (post.Images.Any())
                    {
                        foreach (var image in post.Images)
                        {
                            try
                            {
                                string relativePath;
                                if (image.ImageUrl.StartsWith("http"))
                                {
                                    var uri = new Uri(image.ImageUrl);
                                    relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                                }
                                else
                                {
                                    relativePath = image.ImageUrl.Replace('/', Path.DirectorySeparatorChar);
                                }
                                
                                var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                                if (File.Exists(fullPath))
                                    File.Delete(fullPath);
                            }
                            catch (Exception ex)
                            {
                                _logger.LogWarning(ex, "Error while deleting post image file: {imageUrl}", image.ImageUrl);
                            }
                        }
                        _context.PostImages.RemoveRange(post.Images);
                    }
                    
                    _context.Posts.Remove(post);
                }
            }

            var registrations = await _context.ActivityRegistrations
                .Where(ar => ar.ActivityId == entity.Id)
                .ToListAsync();
            
            if (registrations.Any())
            {
                _context.ActivityRegistrations.RemoveRange(registrations);
            }

            var reviews = await _context.Reviews
                .Where(r => r.ActivityId == entity.Id)
                .ToListAsync();

            if (reviews.Any())
            {
                _context.Reviews.RemoveRange(reviews);
            }

            if (!string.IsNullOrWhiteSpace(entity.ImagePath))
            {
                try
                {
                    string relativePath;
                    if (entity.ImagePath.StartsWith("http"))
                    {
                        var uri = new Uri(entity.ImagePath);
                        relativePath = uri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ImagePath.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting activity image from file system.");
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task<ActivityResponse> ActivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.ActivateAsync(id);
        }

        public async Task<ActivityResponse> DeactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found");

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);

            return await baseState.DeactivateAsync(id);
        }

        public async Task<ActivityResponse> CloseRegistrationsAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found.");

            _logger.LogInformation($"Attempting to close registrations for activity {id} with state: '{entity.ActivityState}'");

            var state = _baseActivityState.GetActivityState(entity.ActivityState);
            _logger.LogInformation($"Retrieved state object of type: {state.GetType().Name}");

            if (state is not RegistrationsOpenActivityState activeState)
            {
                _logger.LogWarning($"Activity {id} has state '{entity.ActivityState}' but expected 'RegistrationsOpenActivityState'. Actual state type: {state.GetType().Name}");
                throw new UserException($"Registrations can only be closed while active. Current state: {entity.ActivityState}");
            }

            _logger.LogInformation($"Calling CloseRegistrationsAsync on RegistrationsOpenActivityState for activity {id}");
            var result = await activeState.CloseRegistrationsAsync(id);
            _logger.LogInformation($"Successfully closed registrations for activity {id}. New state: {result.ActivityState}");
            
            return result;
        }

        public async Task<ActivityResponse> FinishAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                throw new UserException("Activity not found.");

            _logger.LogInformation($"Attempting to finish activity {id} with state: '{entity.ActivityState}'");

            var state = _baseActivityState.GetActivityState(entity.ActivityState);
            _logger.LogInformation($"Retrieved state object of type: {state.GetType().Name}");

            if (state is not RegistrationsClosedActivityState registrationsClosedState)
            {
                _logger.LogWarning($"Activity {id} has state '{entity.ActivityState}' but expected 'RegistrationsClosedActivityState'. Actual state type: {state.GetType().Name}");
                throw new UserException($"You can only finish an activity after closing registrations. Current state: {entity.ActivityState}");
            }

            if (entity.EndTime.HasValue && entity.EndTime > DateTime.Now)
                //throw new UserException("You can't finish the activity before it's scheduled to end.");

            _logger.LogInformation($"Calling FinishAsync on RegistrationsClosedActivityState for activity {id}");
            var result = await registrationsClosedState.FinishAsync(id);
            _logger.LogInformation($"Successfully finished activity {id}. New state: {result.ActivityState}");

            var registrationsToDelete = await _context.ActivityRegistrations
                .Where(ar => ar.ActivityId == id && (ar.Status == Common.Enums.RegistrationStatus.Pending 
                || ar.Status == Common.Enums.RegistrationStatus.Rejected || ar.Status == Common.Enums.RegistrationStatus.Cancelled))
                .ToListAsync();

            if (registrationsToDelete.Any())
            {
                _context.ActivityRegistrations.RemoveRange(registrationsToDelete);
                await _context.SaveChangesAsync();
                _logger.LogInformation($"Cleaned up {registrationsToDelete.Count} registrations for finished activity {id}");
            }

            return result;
        }

        public async Task<ActivityResponse?> UpdateImageAsync(int id, string? imagePath)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            if (!string.IsNullOrWhiteSpace(entity.ImagePath))
            {
                try
                {
                    string relativePath;
                    if (entity.ImagePath.StartsWith("http"))
                    {
                        var oldUri = new Uri(entity.ImagePath);
                        relativePath = oldUri.LocalPath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
                    }
                    else
                    {
                        relativePath = entity.ImagePath.Replace('/', Path.DirectorySeparatorChar);
                    }
                    
                    var fullPath = Path.Combine(_env.WebRootPath, relativePath);

                    if (File.Exists(fullPath))
                        File.Delete(fullPath);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while deleting old image");
                }
            }

            entity.ImagePath = string.IsNullOrWhiteSpace(imagePath) ? "" : imagePath;
            Console.WriteLine("entity.imagePAth: ", entity.ImagePath);
            Console.WriteLine("imagepath:", imagePath);
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public async Task<ActivityResponse?> UpdateSummaryAsync(int id, string summary)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            entity.Summary = summary;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public async Task<ActivityResponse?> TogglePrivacyAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            entity.isPrivate = !entity.isPrivate;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return _mapper.Map<ActivityResponse>(entity);
        }

        public async Task<ActivityResponse?> ReactivateAsync(int id)
        {
            var entity = await _context.Activities.FindAsync(id);
            if (entity == null)
                return null;

            if (entity.ActivityState != nameof(CancelledActivityState))
            {
                throw new UserException("Only cancelled activities can be reactivated.");
            }

            var baseState = _baseActivityState.GetActivityState(entity.ActivityState);
            
            if (baseState is CancelledActivityState cancelledState)
            {
                return await cancelledState.ReactivateAsync(id);
            }

            throw new UserException("Invalid state for reactivation.");
        }

        protected override ActivityResponse MapToResponse(Activity entity)
        {
            return new ActivityResponse
            {
                Id = entity.Id,
                Title = entity.Title,
                Description = entity.Description,
                Summary = entity.Summary,
                isPrivate = entity.isPrivate,
                StartTime = entity.StartTime,
                EndTime = entity.EndTime,
                Latitude = entity.Latitude,
                Longitude = entity.Longitude,
                LocationName = entity.LocationName,
                CityId = entity.CityId,
                CityName = entity.City?.Name ?? string.Empty,
                Fee = entity.Fee,
                TroopId = entity.TroopId,
                TroopName = entity.Troop?.Name ?? string.Empty,
                ActivityTypeId = entity.ActivityTypeId,
                ActivityTypeName = entity.ActivityType?.Name ?? string.Empty,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                ActivityState = entity.ActivityState,
                RegistrationCount = _context.ActivityRegistrations.Where(ar => ar.Status == Common.Enums.RegistrationStatus.Completed).
                    Count(ar => ar.ActivityId == entity.Id),
                ImagePath = entity.ImagePath,
            };
        }

        public async Task<PagedResult<ActivityResponse>> GetForUserAsync(ClaimsPrincipal user, ActivitySearchObject search)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole == "Member")
            {
                var member = await _context.Members
                    .FirstOrDefaultAsync(m => m.Id == userId);
                
                if (member != null)
                {
                    search.ShowPublicAndOwn = true;
                    search.OwnTroopId = member.TroopId;
                }
            }
            else if (userRole == "Troop")
            {
                search.ShowPublicAndOwn = true;
                search.OwnTroopId = userId;
            }

            return await GetAsync(search);
        }

        public async Task<ActivityResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanViewActivityAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to view this activity.");
            }

            return await GetByIdAsync(id);
        }
    }
} 