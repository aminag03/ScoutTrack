using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using ScoutTrack.Model.Requests;
using ScoutTrack.Model.Responses;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Linq;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.Services
{
    public class AuthService : IAuthService
    {
        private readonly ScoutTrackDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthService(ScoutTrackDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<LoginResponse> LoginAsync(LoginRequest request)
        {
            var user = await _context.UserAccounts.FirstOrDefaultAsync(u => u.Username == request.UsernameOrEmail || u.Email == request.UsernameOrEmail);
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                throw new UnauthorizedAccessException("Invalid username or password");

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(
                Environment.GetEnvironmentVariable("JWT__KEY") ?? _configuration["Jwt:Key"] ?? ""
            );
            var issuer = Environment.GetEnvironmentVariable("JWT__ISSUER") ?? _configuration["Jwt:Issuer"];
            var audience = Environment.GetEnvironmentVariable("JWT__AUDIENCE") ?? _configuration["Jwt:Audience"];
            var expiresIn = int.Parse(Environment.GetEnvironmentVariable("JWT__EXPIRESINMINUTES") ?? _configuration["Jwt:ExpiresInMinutes"] ?? "60");

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            };
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddMinutes(expiresIn),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);

            var refreshToken = GenerateRefreshToken();
            var refreshTokenEntity = new RefreshToken
            {
                Token = refreshToken,
                ExpiresAt = DateTime.Now.AddDays(7),
                CreatedAt = DateTime.Now,
                UserAccountId = user.Id,
                IsRevoked = false
            };
            _context.RefreshTokens.Add(refreshTokenEntity);
            user.LastLoginAt = DateTime.Now;
            await _context.SaveChangesAsync();
            await CleanupOldRefreshTokensAsync(user.Id);

            return new LoginResponse
            {
                AccessToken = tokenHandler.WriteToken(token),
                Expiration = tokenDescriptor.Expires ?? DateTime.Now.AddMinutes(expiresIn),
                Username = user.Username,
                Role = user.Role.ToString(),
                RefreshToken = refreshToken
            };
        }

        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(randomNumber);
                return Convert.ToBase64String(randomNumber);
            }
        }

        public async Task<LoginResponse> RefreshTokenAsync(string refreshToken)
        {
            var refreshTokenEntity = await _context.RefreshTokens.Include(rt => rt.UserAccount)
                .FirstOrDefaultAsync(rt => rt.Token == refreshToken && !rt.IsRevoked);
            if (refreshTokenEntity == null || refreshTokenEntity.ExpiresAt < DateTime.Now)
                throw new UnauthorizedAccessException("Invalid or expired refresh token");

            var user = refreshTokenEntity.UserAccount;

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(
                Environment.GetEnvironmentVariable("JWT__KEY") ?? _configuration["Jwt:Key"] ?? ""
            );
            var issuer = Environment.GetEnvironmentVariable("JWT__ISSUER") ?? _configuration["Jwt:Issuer"];
            var audience = Environment.GetEnvironmentVariable("JWT__AUDIENCE") ?? _configuration["Jwt:Audience"];
            var expiresIn = int.Parse(Environment.GetEnvironmentVariable("JWT__EXPIRESINMINUTES") ?? _configuration["Jwt:ExpiresInMinutes"] ?? "60");

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role.ToString()),
            };
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddMinutes(expiresIn),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);

            refreshTokenEntity.IsRevoked = true;

            var newRefreshToken = GenerateRefreshToken();
            var newRefreshTokenEntity = new RefreshToken
            {
                Token = newRefreshToken,
                ExpiresAt = DateTime.Now.AddDays(7),
                CreatedAt = DateTime.Now,
                UserAccountId = user.Id,
                IsRevoked = false
            };
            _context.RefreshTokens.Add(newRefreshTokenEntity);
            await _context.SaveChangesAsync();
            await CleanupOldRefreshTokensAsync(user.Id);

            return new LoginResponse
            {
                AccessToken = tokenHandler.WriteToken(token),
                Expiration = tokenDescriptor.Expires ?? DateTime.Now.AddMinutes(expiresIn),
                Username = user.Username,
                Role = user.Role.ToString(),
                RefreshToken = newRefreshToken
            };
        }

        public async Task LogoutAsync(int userId)
        {
            var tokens = await _context.RefreshTokens.Where(rt => rt.UserAccountId == userId && !rt.IsRevoked && rt.ExpiresAt > DateTime.Now).ToListAsync();
            foreach (var token in tokens)
            {
                token.IsRevoked = true;
            }
            await _context.SaveChangesAsync();
            await CleanupOldRefreshTokensAsync(userId);
        }

        private async Task CleanupOldRefreshTokensAsync(int userId)
        {
            var now = DateTime.Now;
            var oldTokens = _context.RefreshTokens
                .Where(rt => rt.UserAccountId == userId && (rt.IsRevoked || rt.ExpiresAt < now));
            _context.RefreshTokens.RemoveRange(oldTokens);
            await _context.SaveChangesAsync();
        }

        public string GetUserRole(ClaimsPrincipal user)
        {
            return user?.FindFirst(ClaimTypes.Role)?.Value;
        }

        public int? GetUserId(ClaimsPrincipal user)
        {
            var idClaim = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(idClaim, out var id))
                return id;
            return null;
        }

        public bool IsInRole(ClaimsPrincipal user, string role)
        {
            return GetUserRole(user) == role;
        }

        public async Task<CurrentUserResponse?> GetCurrentUserAsync(ClaimsPrincipal user)
        {
            var userId = GetUserId(user);
            var role = GetUserRole(user);

            if (userId == null || string.IsNullOrEmpty(role))
                return null;

            switch (role)
            {
                case "Admin":
                    var admin = await _context.Admins.FirstOrDefaultAsync(a => a.Id == userId);
                    return admin == null ? null : new CurrentUserResponse
                    {
                        Id = admin.Id,
                        Role = "Admin",
                        Username = admin.Username,
                        Email = admin.Email
                    };

                case "Troop":
                    var troop = await _context.Troops.Include(t => t.City).FirstOrDefaultAsync(t => t.Id == userId);
                    return troop == null ? null : new CurrentUserResponse
                    {
                        Id = troop.Id,
                        Role = "Troop",
                        Username = troop.Username,
                        Email = troop.Email,
                        CityName = troop.City?.Name
                    };

                case "Member":
                    var member = await _context.Members
                        .Include(m => m.City)
                        .Include(m => m.Troop)
                        .FirstOrDefaultAsync(m => m.Id == userId);

                    return member == null ? null : new CurrentUserResponse
                    {
                        Id = member.Id,
                        Role = "Member",
                        Username = member.Username,
                        Email = member.Email,
                        CityName = member.City?.Name,
                        TroopName = member.Troop?.Name
                    };

                default:
                    return null;
            }
        }


    }
} 