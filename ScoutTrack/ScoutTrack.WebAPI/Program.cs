using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ScoutTrack.Services;
using ScoutTrack.Services.Database;
using ScoutTrack.Services.Interfaces;
using ScoutTrack.Services.Services;
using ScoutTrack.Services.Services.ActivityStateMachine;
using ScoutTrack.Services.Services.ActivityRegistrationStateMachine;
using ScoutTrack.WebAPI.Filters;
using System.Text;

Env.Load(@"../.env");

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IBadgeService, BadgeService>();
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

// Activity State Machine
builder.Services.AddTransient<BaseActivityState>();
builder.Services.AddTransient<InitialActivityState>();
builder.Services.AddTransient<DraftActivityState>();
builder.Services.AddTransient<ActiveActivityState>();
builder.Services.AddTransient<RegistrationsClosedActivityState>();
builder.Services.AddTransient<CancelledActivityState>();
builder.Services.AddTransient<FinishedActivityState>();

// Activity Registration State Machine
builder.Services.AddTransient<BaseActivityRegistrationState>();
builder.Services.AddTransient<PendingActivityRegistrationState>();
builder.Services.AddTransient<ApprovedActivityRegistrationState>();
builder.Services.AddTransient<RejectedActivityRegistrationState>();
builder.Services.AddTransient<CancelledActivityRegistrationState>();
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
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Sapica.API", Version = "v1" });

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

app.UseAuthentication();
app.UseAuthorization();

app.UseStaticFiles();

app.MapControllers();

app.Run();
