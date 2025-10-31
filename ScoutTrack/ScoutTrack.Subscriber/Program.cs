using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using ScoutTrack.Model.Events;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;
using DotNetEnv;

Console.WriteLine("Starting ScoutTrack Notification Subscriber...");

void TryLoadEnv()
{
    try { Env.Load(); } catch { }
    try { Env.Load(".env"); } catch { }
    try { Env.Load("../.env"); } catch { }
    try { Env.Load("../../.env"); } catch { }
}

TryLoadEnv();

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables()
    .Build();

var connectionString = configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=220188;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";
var options = new DbContextOptionsBuilder<ScoutTrackDbContext>()
    .UseSqlServer(connectionString)
    .Options;

var rabbitHost = Environment.GetEnvironmentVariable("RABBIT_MQ_HOST");
var rabbitUser = Environment.GetEnvironmentVariable("RABBIT_MQ_USER") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBIT_MQ_PASS") ?? "guest";

string rabbitMQConnectionString;
if (!string.IsNullOrWhiteSpace(rabbitHost))
{
    rabbitMQConnectionString = $"host={rabbitHost};username={rabbitUser};password={rabbitPass}";
}
else
{
    var connectionStringEnv = Environment.GetEnvironmentVariable("RABBITMQ_CONNECTIONSTRING");
    if (!string.IsNullOrWhiteSpace(connectionStringEnv))
    {
        rabbitMQConnectionString = connectionStringEnv;
    }
    else
    {
        rabbitMQConnectionString = configuration["RabbitMQ:ConnectionString"]
            ?? "host=localhost;username=guest;password=guest";
    }
}

var bus = RabbitHutch.CreateBus(rabbitMQConnectionString);

Console.WriteLine("Connected to RabbitMQ. Waiting for notifications...");

await bus.PubSub.SubscribeAsync<NotificationEvent>(
    "notification_subscriber",
    async notification =>
    {
        try
        {
            Console.WriteLine($"Received notification: {notification.Message}");
            
            using var context = new ScoutTrackDbContext(options);
            
            var notifications = new List<Notification>();
            
            foreach (var userId in notification.UserIds)
            {
                var dbNotification = new Notification
                {
                    Message = notification.Message,
                    ReceiverId = userId,
                    SenderId = notification.SenderId,
                    CreatedAt = notification.CreatedAt,
                    IsRead = false
                };
                
                notifications.Add(dbNotification);
            }
            
            await context.Notifications.AddRangeAsync(notifications);
            await context.SaveChangesAsync();
            
            Console.WriteLine($"Saved {notifications.Count} notifications to database");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing notification: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    },
    configure => configure.WithQueueName("notification.created")
);

Console.WriteLine("Subscriber is running. Waiting for messages...");
await Task.Delay(Timeout.InfiniteTimeSpan);