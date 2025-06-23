using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace ScoutTrack.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<ScoutTrackDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}
