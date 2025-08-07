using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Services.Extensions;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services.ActivityRegistrationStateMachine;
using System.Security.Claims;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Services
{
    public class ActivityRegistrationService : BaseCRUDService<ActivityRegistrationResponse, ActivityRegistrationSearchObject, ActivityRegistration, ActivityRegistrationUpsertRequest, ActivityRegistrationUpsertRequest>, IActivityRegistrationService
    {
        private readonly ScoutTrackDbContext _context;
        protected readonly BaseActivityRegistrationState _baseActivityRegistrationState;
        private readonly IAccessControlService _accessControlService;

        public ActivityRegistrationService(ScoutTrackDbContext context, IMapper mapper, BaseActivityRegistrationState baseActivityRegistrationState, IAccessControlService accessControlService) 
            : base(context, mapper)
        {
            _context = context;
            _baseActivityRegistrationState = baseActivityRegistrationState;
            _accessControlService = accessControlService;
        }

        public override async Task<ActivityRegistrationResponse> CreateAsync(ActivityRegistrationUpsertRequest request)
        {
            // This method is now deprecated in favor of CreateForUserAsync
            // which automatically sets member ID from claims and status to Pending
            throw new UserException("Use CreateForUserAsync instead of CreateAsync for activity registrations.");
        }

        public async Task<ActivityRegistrationResponse> ApproveAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                throw new UserException("Activity registration not found.");

            var state = _baseActivityRegistrationState.GetActivityRegistrationState(GetStateNameFromStatus(entity.Status));
            return await state.ApproveAsync(id);
        }

        public async Task<ActivityRegistrationResponse> RejectAsync(int id, string reason = "")
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                throw new UserException("Activity registration not found.");

            var state = _baseActivityRegistrationState.GetActivityRegistrationState(GetStateNameFromStatus(entity.Status));
            return await state.RejectAsync(id, reason);
        }

        public async Task<ActivityRegistrationResponse> CancelAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                throw new UserException("Activity registration not found.");

            var state = _baseActivityRegistrationState.GetActivityRegistrationState(GetStateNameFromStatus(entity.Status));
            return await state.CancelAsync(id);
        }

        public async Task<ActivityRegistrationResponse> CompleteAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                throw new UserException("Activity registration not found.");

            var state = _baseActivityRegistrationState.GetActivityRegistrationState(GetStateNameFromStatus(entity.Status));
            return await state.CompleteAsync(id);
        }

        public async Task<PagedResult<ActivityRegistrationResponse>> GetForUserAsync(ClaimsPrincipal user, ActivityRegistrationSearchObject search)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole == "Member")
            {
                search.MemberId = userId;
            }
            else if (userRole == "Troop")
            {
                var troopActivityIds = await _context.Activities
                    .Where(a => a.TroopId == userId)
                    .Select(a => a.Id)
                    .ToListAsync();
                
                if (!troopActivityIds.Any())
                {
                    return new PagedResult<ActivityRegistrationResponse>
                    {
                        Items = new List<ActivityRegistrationResponse>(),
                        TotalCount = 0
                    };
                }
                
                if (search.ActivityId.HasValue && !troopActivityIds.Contains(search.ActivityId.Value))
                {
                    throw new UnauthorizedAccessException("You do not have permission to view registrations for this activity.");
                }
                
                if (!search.ActivityId.HasValue)
                {
                    search.OwnTroopActivityIds = troopActivityIds;
                }
            }

            return await GetAsync(search);
        }

        public async Task<ActivityRegistrationResponse> CreateForUserAsync(ClaimsPrincipal user, ActivityRegistrationUpsertRequest request)
        {
            var userId = int.Parse(user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var userRole = user.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole != "Member")
            {
                throw new UnauthorizedAccessException("Only members can register for activities.");
            }

            if (!await _accessControlService.CanRegisterForActivityAsync(user, request.ActivityId))
            {
                throw new UnauthorizedAccessException("You do not have permission to register for this activity.");
            }

            var registrationRequest = new ActivityRegistrationUpsertRequest
            {
                ActivityId = request.ActivityId,
                Notes = request.Notes
            };

            var entity = new ActivityRegistration();
            _mapper.Map(registrationRequest, entity);
            entity.MemberId = userId;
            entity.Status = Common.Enums.RegistrationStatus.Pending;
            entity.RegisteredAt = DateTime.UtcNow;

            var existingRegistration = await _context.ActivityRegistrations
                .FirstOrDefaultAsync(ar => ar.ActivityId == request.ActivityId && ar.MemberId == userId);

            if (existingRegistration != null)
                throw new UserException("Registration already exists for this member and activity.");

            _context.ActivityRegistrations.Add(entity);
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public async Task<ActivityRegistrationResponse> ApproveForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanApproveActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to approve this registration.");
            }

            return await ApproveAsync(id);
        }

        public async Task<ActivityRegistrationResponse> RejectForUserAsync(ClaimsPrincipal user, int id, string reason = "")
        {
            if (!await _accessControlService.CanApproveActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to reject this registration.");
            }

            return await RejectAsync(id, reason);
        }

        public async Task<ActivityRegistrationResponse> CancelForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanCancelActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to cancel this registration.");
            }

            return await CancelAsync(id);
        }

        public async Task<ActivityRegistrationResponse> CompleteForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanCompleteActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to complete this registration.");
            }

            return await CompleteAsync(id);
        }

        public async Task<ActivityRegistrationResponse?> GetByIdForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanViewActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to view this registration.");
            }

            return await GetByIdAsync(id);
        }

        public async Task<ActivityRegistrationResponse> UpdateForUserAsync(ClaimsPrincipal user, int id, ActivityRegistrationUpsertRequest request)
        {
            if (!await _accessControlService.CanModifyActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to modify this registration.");
            }

            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                throw new UserException("Activity registration not found.");

            entity.Notes = request.Notes;
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public async Task<bool> DeleteForUserAsync(ClaimsPrincipal user, int id)
        {
            if (!await _accessControlService.CanModifyActivityRegistrationAsync(user, id))
            {
                throw new UnauthorizedAccessException("You do not have permission to delete this registration.");
            }

            return await DeleteAsync(id);
        }

        private string GetStateNameFromStatus(Common.Enums.RegistrationStatus status)
        {
            return status switch
            {
                Common.Enums.RegistrationStatus.Pending => nameof(PendingActivityRegistrationState),
                Common.Enums.RegistrationStatus.Approved => nameof(ApprovedActivityRegistrationState),
                Common.Enums.RegistrationStatus.Rejected => nameof(RejectedActivityRegistrationState),
                Common.Enums.RegistrationStatus.Cancelled => nameof(CancelledActivityRegistrationState),
                Common.Enums.RegistrationStatus.Completed => nameof(CompletedActivityRegistrationState),
                _ => throw new Exception($"Unknown registration status: {status}")
            };
        }

        protected override IQueryable<ActivityRegistration> ApplyFilter(IQueryable<ActivityRegistration> query, ActivityRegistrationSearchObject search)
        {
            if (search.ActivityId.HasValue)
                query = query.Where(ar => ar.ActivityId == search.ActivityId.Value);

            if (search.MemberId.HasValue)
                query = query.Where(ar => ar.MemberId == search.MemberId.Value);

            if (search.Status.HasValue)
                query = query.Where(ar => ar.Status == search.Status.Value);

            if (search.OwnTroopActivityIds != null && search.OwnTroopActivityIds.Any())
            {
                query = query.Where(ar => search.OwnTroopActivityIds.Contains(ar.ActivityId));
            }

            return query;
        }

        public override async Task<PagedResult<ActivityRegistrationResponse>> GetAsync(ActivityRegistrationSearchObject search)
        {
            var query = _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
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

            var list = await query.ToListAsync();
            return new PagedResult<ActivityRegistrationResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<ActivityRegistrationResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.ActivityRegistrations
                .Include(ar => ar.Activity)
                .Include(ar => ar.Member)
                .FirstOrDefaultAsync(ar => ar.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override ActivityRegistrationResponse MapToResponse(ActivityRegistration entity)
        {
            return new ActivityRegistrationResponse
            {
                Id = entity.Id,
                RegisteredAt = entity.RegisteredAt,
                ActivityId = entity.ActivityId,
                MemberId = entity.MemberId,
                Status = entity.Status,
                Notes = entity.Notes,
                ActivityTitle = entity.Activity?.Title ?? string.Empty,
                MemberName = entity.Member?.FirstName + " " + entity.Member?.LastName ?? string.Empty
            };
        }
    }
} 