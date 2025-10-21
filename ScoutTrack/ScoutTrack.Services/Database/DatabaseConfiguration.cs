using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using ScoutTrack.Services.Services;
using ScoutTrack.Services.Interfaces;

namespace ScoutTrack.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<ScoutTrackDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddRabbitMQServices(this IServiceCollection services)
        {
            services.AddSingleton<IRabbitMQService, RabbitMQService>();
            services.AddTransient<INotificationPublisherService, NotificationPublisherService>();
        }
    }
}
