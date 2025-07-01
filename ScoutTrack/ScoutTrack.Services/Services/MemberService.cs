using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
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
using System.Threading.Tasks;

namespace ScoutTrack.Services
{
    public class MemberService : BaseCRUDService<MemberResponse, MemberSearchObject, Member, MemberUpsertRequest, MemberUpsertRequest>, IMemberService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly ILogger<MemberService> _logger;

        public MemberService(ScoutTrackDbContext context, IMapper mapper, ILogger<MemberService> logger) : base(context, mapper) 
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<Member> ApplyFilter(IQueryable<Member> query, MemberSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(m => m.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(m => m.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.FirstName))
            {
                query = query.Where(m => m.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrEmpty(search.LastName))
            {
                query = query.Where(m => m.LastName.Contains(search.LastName));
            }

            if (search.TroopId.HasValue)
            {
                query = query.Where(m => m.TroopId == search.TroopId.Value);
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(m => m.CityId == search.CityId.Value);
            }

            if (search.Gender.HasValue)
            {
                query = query.Where(m => m.Gender == search.Gender.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(m => m.Username.Contains(search.FTS) || 
                                        m.Email.Contains(search.FTS) || 
                                        m.FirstName.Contains(search.FTS) ||
                                        m.LastName.Contains(search.FTS));
            }
            return query;
        }

        protected override async Task BeforeInsert(Member entity, MemberUpsertRequest request)
        {
            entity.Role = Role.Member;
            
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email))
                throw new UserException("User with this email already exists.");

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");

            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            entity.Gender = request.Gender;
        }

        protected override async Task BeforeUpdate(Member entity, MemberUpsertRequest request)
        {
            if (await _context.UserAccounts.AnyAsync(ua => ua.Username == request.Username && ua.Id != entity.Id))
                throw new UserException("User with this username already exists.");

            if (await _context.UserAccounts.AnyAsync(ua => ua.Email == request.Email && ua.Id != entity.Id))
                throw new UserException("User with this email already exists.");

            if (!await _context.Troops.AnyAsync(t => t.Id == request.TroopId))
                throw new UserException($"Troop with ID {request.TroopId} does not exist.");

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new UserException($"City with ID {request.CityId} does not exist.");

            entity.Gender = request.Gender;
        }

        public async Task ChangePasswordAsync(int memberId, string newPassword)
        {
            var member = await _context.Members.FindAsync(memberId)
                ?? throw new KeyNotFoundException("Member not found.");

            if (string.IsNullOrWhiteSpace(newPassword))
                throw new ArgumentException("Password is required.");

            member.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            await _context.SaveChangesAsync();
        }
    }
} 