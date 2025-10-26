using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ScoutTrack.Model.Events;
using ScoutTrack.Services;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services;
using ScoutTrack.Services.Services.ActivityStateMachine;
using ScoutTrack.Services.Services.ActivityRegistrationStateMachine;
using ScoutTrack.WebAPI.Filters;
using ScoutTrack.WebAPI.Hubs;
using System.Text;
using Microsoft.AspNetCore.SignalR;

Env.Load(@"../.env");

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddMemoryCache();
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddTransient<IBadgeService, BadgeService>();
builder.Services.AddTransient<IBadgeRequirementService, BadgeRequirementService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IAdminService, AdminService>();
builder.Services.AddTransient<ITroopService, TroopService>();
builder.Services.AddTransient<IMemberService, MemberService>();
builder.Services.AddTransient<IActivityTypeService, ActivityTypeService>();
builder.Services.AddTransient<IActivityService, ActivityService>();
builder.Services.AddTransient<IAuthService, AuthService>();
builder.Services.AddTransient<IAccessControlService, AccessControlService>();
builder.Services.AddTransient<IEquipmentService, EquipmentService>();
builder.Services.AddTransient<IActivityEquipmentService, ActivityEquipmentService>();
builder.Services.AddTransient<IActivityRegistrationService, ActivityRegistrationService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IPostService, PostService>();
builder.Services.AddTransient<ICommentService, CommentService>();
builder.Services.AddTransient<ILikeService, LikeService>();
builder.Services.AddTransient<IMemberBadgeService, MemberBadgeService>();
builder.Services.AddTransient<IMemberBadgeProgressService, MemberBadgeProgressService>();
builder.Services.AddTransient<IDocumentService, DocumentService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IFriendshipService, FriendshipService>();

// Register RabbitMQ services
builder.Services.AddRabbitMQServices();

// Register background service for notification broadcasting
builder.Services.AddHostedService<ScoutTrack.WebAPI.Services.NotificationBroadcastService>();

// Activity State Machine
builder.Services.AddTransient<BaseActivityState>();
builder.Services.AddTransient<InitialActivityState>();
builder.Services.AddTransient<DraftActivityState>();
builder.Services.AddTransient<RegistrationsOpenActivityState>();
builder.Services.AddTransient<RegistrationsClosedActivityState>();
builder.Services.AddTransient<CancelledActivityState>();
builder.Services.AddTransient<FinishedActivityState>();

// Activity Registration State Machine
builder.Services.AddTransient<BaseActivityRegistrationState>();
builder.Services.AddTransient<PendingActivityRegistrationState>();
builder.Services.AddTransient<ApprovedActivityRegistrationState>();
builder.Services.AddTransient<RejectedActivityRegistrationState>();
builder.Services.AddTransient<CompletedActivityRegistrationState>();


builder.Services.AddMapster();
// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=localhost;Database=220188;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";
builder.Services.AddDatabaseServices(connectionString);

// JWT Authentication
string jwtKey = Environment.GetEnvironmentVariable("JWT__KEY") ?? builder.Configuration["Jwt:Key"] ?? "";
string jwtIssuer = Environment.GetEnvironmentVariable("JWT__ISSUER") ?? builder.Configuration["Jwt:Issuer"] ?? "";
string jwtAudience = Environment.GetEnvironmentVariable("JWT__AUDIENCE") ?? builder.Configuration["Jwt:Audience"] ?? "";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddControllers( x =>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "ScoutTrack.API", Version = "v1" });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter 'Bearer' followed by your JWT token in the text input below.\n\nExample: `Bearer eyJhbGci...`"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// Ensure the database is created
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ScoutTrackDbContext>();
    dbContext.Database.EnsureCreated();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.UseStaticFiles();

app.MapControllers();

// Map SignalR Hub
app.MapHub<NotificationHub>("/notificationhub");

app.Run();
