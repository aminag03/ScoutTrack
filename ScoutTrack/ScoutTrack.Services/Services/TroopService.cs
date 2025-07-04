using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Model.SearchObjects;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using ScoutTrack.Common.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScoutTrack.Model.Exceptions;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.Services
{
    public class TroopService : BaseCRUDService<TroopResponse, TroopSearchObject, Troop, TroopUpsertRequest, TroopUpsertRequest>, ITroopService
    {
        private readonly ScoutTrackDbContext _context;

        public TroopService(ScoutTrackDbContext context, IMapper mapper) : base(context, mapper) 
        {
            _context = context;
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
            return query;
        }

        protected override async Task BeforeInsert(Troop entity, TroopUpsertRequest request)
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

        protected override async Task BeforeUpdate(Troop entity, TroopUpsertRequest request)
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

        public async Task ChangePasswordAsync(int troopId, string newPassword)
        {
            var troop = await _context.Troops.FindAsync(troopId)
                ?? throw new KeyNotFoundException("Troop not found.");

            if (string.IsNullOrWhiteSpace(newPassword))
                throw new ArgumentException("Password is required.");

            troop.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            await _context.SaveChangesAsync();
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var members = _context.Members.Where(m => m.TroopId == id);
            _context.Members.RemoveRange(members);
            await _context.SaveChangesAsync();

            return await base.DeleteAsync(id);
        }
    }
} 