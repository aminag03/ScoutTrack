using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using ScoutTrack.Model.Events;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Database.Entities;

Console.WriteLine("Starting ScoutTrack Notification Subscriber...");

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false)
    .AddEnvironmentVariables()
    .Build();

var connectionString = configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=220188;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";
var options = new DbContextOptionsBuilder<ScoutTrackDbContext>()
    .UseSqlServer(connectionString)
    .Options;

var rabbitMQConnectionString = configuration["RabbitMQ:ConnectionString"] ?? "host=localhost";
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

Console.WriteLine("Subscriber is running. Press any key to exit...");
Console.ReadKey();

bus.Dispose();