using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class init : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ActivityTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ActivityTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Badges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Badges", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Latitude = table.Column<double>(type: "float", nullable: false),
                    Longitude = table.Column<double>(type: "float", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Equipments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Equipments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserAccounts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Role = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserAccounts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BadgeRequirements",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BadgeId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BadgeRequirements", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BadgeRequirements_Badges_BadgeId",
                        column: x => x.BadgeId,
                        principalTable: "Badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Admins",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Admins", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Admins_UserAccounts_Id",
                        column: x => x.Id,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Message = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Token = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    IsRevoked = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Troops",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: false),
                    Latitude = table.Column<double>(type: "float", nullable: false),
                    Longitude = table.Column<double>(type: "float", nullable: false),
                    ContactPhone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    LogoUrl = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Troops", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Troops_Cities_CityId",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Troops_UserAccounts_Id",
                        column: x => x.Id,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Documents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    FilePath = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AdminId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Documents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Documents_Admins_AdminId",
                        column: x => x.AdminId,
                        principalTable: "Admins",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Activities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Latitude = table.Column<double>(type: "float", nullable: false),
                    Longitude = table.Column<double>(type: "float", nullable: false),
                    Fee = table.Column<decimal>(type: "decimal(18,2)", precision: 10, scale: 2, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    TroopId = table.Column<int>(type: "int", nullable: false),
                    ActivityTypeId = table.Column<int>(type: "int", nullable: false),
                    ActivityState = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Activities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Activities_ActivityTypes_ActivityTypeId",
                        column: x => x.ActivityTypeId,
                        principalTable: "ActivityTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_Troops_TroopId",
                        column: x => x.TroopId,
                        principalTable: "Troops",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Members",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    BirthDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Gender = table.Column<int>(type: "int", nullable: false),
                    ContactPhone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    ProfilePictureUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TroopId = table.Column<int>(type: "int", nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Members", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Members_Cities_CityId",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_Troops_TroopId",
                        column: x => x.TroopId,
                        principalTable: "Troops",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_UserAccounts_Id",
                        column: x => x.Id,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ActivityEquipments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ActivityId = table.Column<int>(type: "int", nullable: false),
                    EquipmentId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ActivityEquipments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ActivityEquipments_Activities_ActivityId",
                        column: x => x.ActivityId,
                        principalTable: "Activities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ActivityEquipments_Equipments_EquipmentId",
                        column: x => x.EquipmentId,
                        principalTable: "Equipments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Posts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ActivityId = table.Column<int>(type: "int", nullable: false),
                    CreatedById = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Posts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Posts_Activities_ActivityId",
                        column: x => x.ActivityId,
                        principalTable: "Activities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Posts_UserAccounts_CreatedById",
                        column: x => x.CreatedById,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ActivityMember",
                columns: table => new
                {
                    ActivitiesId = table.Column<int>(type: "int", nullable: false),
                    ParticipantsId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ActivityMember", x => new { x.ActivitiesId, x.ParticipantsId });
                    table.ForeignKey(
                        name: "FK_ActivityMember_Activities_ActivitiesId",
                        column: x => x.ActivitiesId,
                        principalTable: "Activities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ActivityMember_Members_ParticipantsId",
                        column: x => x.ParticipantsId,
                        principalTable: "Members",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ActivityRegistrations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RegisteredAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ActivityId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ActivityRegistrations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ActivityRegistrations_Activities_ActivityId",
                        column: x => x.ActivityId,
                        principalTable: "Activities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ActivityRegistrations_Members_MemberId",
                        column: x => x.MemberId,
                        principalTable: "Members",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Friendships",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RequesterId = table.Column<int>(type: "int", nullable: false),
                    ResponderId = table.Column<int>(type: "int", nullable: false),
                    RequestedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RespondedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Friendships", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Friendships_Members_RequesterId",
                        column: x => x.RequesterId,
                        principalTable: "Members",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Friendships_Members_ResponderId",
                        column: x => x.ResponderId,
                        principalTable: "Members",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MemberBadges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MemberId = table.Column<int>(type: "int", nullable: false),
                    BadgeId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberBadges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MemberBadges_Badges_BadgeId",
                        column: x => x.BadgeId,
                        principalTable: "Badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MemberBadges_Members_MemberId",
                        column: x => x.MemberId,
                        principalTable: "Members",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    ActivityId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_Activities_ActivityId",
                        column: x => x.ActivityId,
                        principalTable: "Activities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reviews_Members_MemberId",
                        column: x => x.MemberId,
                        principalTable: "Members",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Comments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Content = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PostId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Comments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Comments_Members_MemberId",
                        column: x => x.MemberId,
                        principalTable: "Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Comments_Posts_PostId",
                        column: x => x.PostId,
                        principalTable: "Posts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Likes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LikedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PostId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Likes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Likes_Members_MemberId",
                        column: x => x.MemberId,
                        principalTable: "Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Likes_Posts_PostId",
                        column: x => x.PostId,
                        principalTable: "Posts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PostImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageUrl = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PostId = table.Column<int>(type: "int", nullable: false),
                    IsCoverPhoto = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PostImages_Posts_PostId",
                        column: x => x.PostId,
                        principalTable: "Posts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MemberBadgeProgresses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MemberBadgeId = table.Column<int>(type: "int", nullable: false),
                    RequirementId = table.Column<int>(type: "int", nullable: false),
                    IsCompleted = table.Column<bool>(type: "bit", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberBadgeProgresses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MemberBadgeProgresses_BadgeRequirements_RequirementId",
                        column: x => x.RequirementId,
                        principalTable: "BadgeRequirements",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_MemberBadgeProgresses_MemberBadges_MemberBadgeId",
                        column: x => x.MemberBadgeId,
                        principalTable: "MemberBadges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Badges",
                columns: new[] { "Id", "CreatedAt", "Description", "ImageUrl", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 21, 20, 1, 37, 409, DateTimeKind.Utc).AddTicks(7056), "Basic first aid skills", "", "First Aid", null },
                    { 2, new DateTime(2025, 7, 21, 20, 1, 37, 409, DateTimeKind.Utc).AddTicks(7073), "Learn how to safely handle fire", "", "Fire Safety", null },
                    { 3, new DateTime(2025, 7, 21, 20, 1, 37, 409, DateTimeKind.Utc).AddTicks(7078), "Orientation and map skills", "", "Map Reading", null }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "CreatedAt", "Latitude", "Longitude", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9755), 43.856299999999997, 18.4131, "Sarajevo", null },
                    { 2, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9794), 44.772199999999998, 17.190999999999999, "Banja Luka", null },
                    { 3, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9827), 44.539999999999999, 18.678999999999998, "Tuzla", null },
                    { 4, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9831), 44.203600000000002, 17.9084, "Zenica", null },
                    { 5, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9834), 43.3431, 17.8078, "Mostar", null },
                    { 6, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9842), 44.816699999999997, 15.8667, "Bihać", null },
                    { 7, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9846), 44.755800000000001, 19.214400000000001, "Bijeljina", null },
                    { 8, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9849), 44.981900000000003, 16.7133, "Prijedor", null },
                    { 9, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9853), 44.875599999999999, 18.802, "Brčko", null },
                    { 10, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9859), 44.737200000000001, 18.083300000000001, "Doboj", null },
                    { 11, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9862), 44.994399999999999, 15.8225, "Cazin", null },
                    { 12, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9866), 42.711399999999998, 18.3444, "Trebinje", null },
                    { 13, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9870), 44.369199999999999, 19.106400000000001, "Zvornik", null },
                    { 14, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9875), 45.212200000000003, 15.827500000000001, "Velika Kladuša", null },
                    { 15, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9879), 44.884999999999998, 18.453299999999999, "Gradačac", null },
                    { 16, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9882), 44.4178, 18.671700000000001, "Gračanica", null },
                    { 17, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9886), 44.229399999999998, 17.660299999999999, "Travnik", null },
                    { 18, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9908), 44.767200000000003, 16.686699999999998, "Sanski Most", null },
                    { 19, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9912), 44.032499999999999, 17.4556, "Bugojno", null },
                    { 20, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9916), 43.983899999999998, 18.185300000000002, "Visoko", null },
                    { 21, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9919), 44.147500000000001, 18.177199999999999, "Kakanj", null },
                    { 22, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9922), 44.543900000000001, 18.648599999999998, "Lukavac", null },
                    { 23, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9926), 44.555, 18.487200000000001, "Srebrenik", null },
                    { 24, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9929), 44.444200000000002, 18.223600000000001, "Zavidovići", null },
                    { 25, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9933), 43.671700000000001, 18.947199999999999, "Goražde", null },
                    { 26, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9936), 43.648600000000002, 17.861899999999999, "Konjic", null },
                    { 27, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9939), 43.353099999999998, 17.431699999999999, "Široki Brijeg", null },
                    { 28, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9943), 43.109400000000001, 17.6953, "Čapljina", null },
                    { 29, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9946), 43.467500000000001, 17.375299999999999, "Grude", null },
                    { 30, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9949), 44.342799999999997, 17.2714, "Jajce", null },
                    { 31, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9952), 44.578099999999999, 17.1539, "Mrkonjić-Grad", null },
                    { 32, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9956), 44.968600000000002, 18.051100000000002, "Modriča", null },
                    { 33, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9959), 44.883299999999998, 16.149999999999999, "Bosanska Krupa", null },
                    { 34, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9965), 44.272199999999998, 18.1053, "Kiseljak", null },
                    { 35, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9969), 43.202500000000001, 17.684699999999999, "Čitluk", null },
                    { 36, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9974), 42.925800000000002, 17.607800000000001, "Neum", null },
                    { 37, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9980), 43.825299999999999, 17.015599999999999, "Livno", null },
                    { 38, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9983), 43.649999999999999, 17.216699999999999, "Tomislav-Grad", null },
                    { 39, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9986), 44.227499999999999, 17.659199999999998, "Novi Travnik", null },
                    { 40, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9989), 43.4925, 18.805599999999998, "Foča", null },
                    { 41, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9992), 44.559699999999999, 16.049700000000001, "Bosanski Petrovac", null },
                    { 42, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9996), 44.4056, 18.531400000000001, "Banovići", null },
                    { 43, new DateTime(2025, 7, 21, 20, 1, 36, 43, DateTimeKind.Utc).AddTicks(9999), 44.445300000000003, 18.585599999999999, "Olovo", null },
                    { 44, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(2), 43.957500000000003, 18.344999999999999, "Ilijaš", null },
                    { 45, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(4), 44.6111, 18.4178, "Tešanj", null },
                    { 46, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(12), 44.536900000000003, 18.704999999999998, "Kalesija", null },
                    { 47, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(14), 43.835000000000001, 17.5733, "Prozor", null },
                    { 49, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(17), 45.145299999999999, 17.2592, "Bosanska Gradiška", null },
                    { 50, new DateTime(2025, 7, 21, 20, 1, 36, 44, DateTimeKind.Utc).AddTicks(20), 43.059699999999999, 17.944400000000002, "Stolac", null }
                });

            migrationBuilder.InsertData(
                table: "UserAccounts",
                columns: new[] { "Id", "CreatedAt", "Email", "IsActive", "LastLoginAt", "PasswordHash", "Role", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 21, 20, 1, 36, 405, DateTimeKind.Utc).AddTicks(3392), "admin@scouttrack.ba", true, null, "$2a$11$L2RZKdM5Nb5CaZimLUAcx.nJLfCaKQz2s.pNpK54o787cRA7IqwdC", 0, null, "admin" },
                    { 2, new DateTime(2025, 7, 21, 20, 1, 36, 405, DateTimeKind.Utc).AddTicks(4550), "troopbl@scouttrack.ba", true, null, "$2a$11$qxgHFggQm9J7pPevh.NvmuUtBzxaweAmR4ee8l8c6aIu6fDe5nvzy", 1, null, "troopbl" },
                    { 3, new DateTime(2025, 7, 21, 20, 1, 36, 738, DateTimeKind.Utc).AddTicks(9895), "troopsarajevo@scouttrack.ba", true, null, "$2a$11$E7pCmoJHtzi5vh0OAn9yvuri1PvqPg0p7uXBbCw7pPxtx4zEsiisy", 1, null, "troopsarajevo" },
                    { 4, new DateTime(2025, 7, 21, 20, 1, 37, 67, DateTimeKind.Utc).AddTicks(5687), "troopmostar@scouttrack.ba", true, null, "$2a$11$EpS6Hk8gzq7Kkwf0/UWrlO3dHP04SUf3HKHS7CVzAy/2gXtxXGjwa", 1, null, "troopmostar" },
                    { 5, new DateTime(2025, 7, 21, 20, 1, 37, 409, DateTimeKind.Utc).AddTicks(7236), "scout1@scouttrack.ba", true, null, "$2a$11$4GAe8FsfIBcJjlewbf3AieBdpQhz7HLAxGrNT93zWlOZcaATfxriW", 2, null, "scout1" },
                    { 6, new DateTime(2025, 7, 21, 20, 1, 37, 794, DateTimeKind.Utc).AddTicks(5320), "scout2@scouttrack.ba", true, null, "$2a$11$1169o4BZRA/2W/5ObgXEoOn5X.UMKhSgwBv6Uk5IvtNauh2HHNFFq", 2, null, "scout2" }
                });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "FullName" },
                values: new object[] { 1, "" });

            migrationBuilder.InsertData(
                table: "Troops",
                columns: new[] { "Id", "CityId", "ContactPhone", "Latitude", "LogoUrl", "Longitude", "Name" },
                values: new object[,]
                {
                    { 2, 2, "", 0.0, "", 0.0, "Troop Banja Luka" },
                    { 3, 1, "", 0.0, "", 0.0, "Troop Sarajevo" },
                    { 4, 5, "", 0.0, "", 0.0, "Troop Mostar" }
                });

            migrationBuilder.InsertData(
                table: "Members",
                columns: new[] { "Id", "BirthDate", "CityId", "ContactPhone", "FirstName", "Gender", "LastName", "ProfilePictureUrl", "TroopId" },
                values: new object[,]
                {
                    { 5, new DateTime(2005, 5, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "", "John", 0, "Doe", "", 2 },
                    { 6, new DateTime(2003, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "", "Jane", 1, "Doe", "", 3 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Activities_ActivityTypeId",
                table: "Activities",
                column: "ActivityTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_Title",
                table: "Activities",
                column: "Title");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_TroopId",
                table: "Activities",
                column: "TroopId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityEquipments_ActivityId",
                table: "ActivityEquipments",
                column: "ActivityId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityEquipments_EquipmentId",
                table: "ActivityEquipments",
                column: "EquipmentId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityMember_ParticipantsId",
                table: "ActivityMember",
                column: "ParticipantsId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityRegistrations_ActivityId_MemberId",
                table: "ActivityRegistrations",
                columns: new[] { "ActivityId", "MemberId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ActivityRegistrations_MemberId",
                table: "ActivityRegistrations",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityTypes_Name",
                table: "ActivityTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_BadgeRequirements_BadgeId_Description",
                table: "BadgeRequirements",
                columns: new[] { "BadgeId", "Description" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Badges_Name",
                table: "Badges",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_Name",
                table: "Cities",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Comments_MemberId",
                table: "Comments",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_PostId_MemberId_CreatedAt",
                table: "Comments",
                columns: new[] { "PostId", "MemberId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Documents_AdminId",
                table: "Documents",
                column: "AdminId");

            migrationBuilder.CreateIndex(
                name: "IX_Documents_Title",
                table: "Documents",
                column: "Title");

            migrationBuilder.CreateIndex(
                name: "IX_Equipments_Name",
                table: "Equipments",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Friendships_RequesterId_ResponderId",
                table: "Friendships",
                columns: new[] { "RequesterId", "ResponderId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Friendships_ResponderId",
                table: "Friendships",
                column: "ResponderId");

            migrationBuilder.CreateIndex(
                name: "IX_Likes_MemberId",
                table: "Likes",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Likes_PostId_MemberId",
                table: "Likes",
                columns: new[] { "PostId", "MemberId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberBadgeProgresses_MemberBadgeId_RequirementId",
                table: "MemberBadgeProgresses",
                columns: new[] { "MemberBadgeId", "RequirementId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberBadgeProgresses_RequirementId",
                table: "MemberBadgeProgresses",
                column: "RequirementId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberBadges_BadgeId",
                table: "MemberBadges",
                column: "BadgeId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberBadges_MemberId_BadgeId",
                table: "MemberBadges",
                columns: new[] { "MemberId", "BadgeId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Members_CityId",
                table: "Members",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_TroopId",
                table: "Members",
                column: "TroopId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_CreatedAt",
                table: "Notifications",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserAccountId",
                table: "Notifications",
                column: "UserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_PostImages_PostId_ImageUrl",
                table: "PostImages",
                columns: new[] { "PostId", "ImageUrl" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Posts_ActivityId",
                table: "Posts",
                column: "ActivityId");

            migrationBuilder.CreateIndex(
                name: "IX_Posts_CreatedAt",
                table: "Posts",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Posts_CreatedById",
                table: "Posts",
                column: "CreatedById");

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_Token",
                table: "RefreshTokens",
                column: "Token",
                unique: true,
                filter: "[Token] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserAccountId",
                table: "RefreshTokens",
                column: "UserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ActivityId_MemberId",
                table: "Reviews",
                columns: new[] { "ActivityId", "MemberId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_MemberId",
                table: "Reviews",
                column: "MemberId");

            migrationBuilder.CreateIndex(
                name: "IX_Troops_CityId",
                table: "Troops",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_Troops_Name",
                table: "Troops",
                column: "Name",
                unique: true,
                filter: "[Name] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ActivityEquipments");

            migrationBuilder.DropTable(
                name: "ActivityMember");

            migrationBuilder.DropTable(
                name: "ActivityRegistrations");

            migrationBuilder.DropTable(
                name: "Comments");

            migrationBuilder.DropTable(
                name: "Documents");

            migrationBuilder.DropTable(
                name: "Friendships");

            migrationBuilder.DropTable(
                name: "Likes");

            migrationBuilder.DropTable(
                name: "MemberBadgeProgresses");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "PostImages");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "Equipments");

            migrationBuilder.DropTable(
                name: "Admins");

            migrationBuilder.DropTable(
                name: "BadgeRequirements");

            migrationBuilder.DropTable(
                name: "MemberBadges");

            migrationBuilder.DropTable(
                name: "Posts");

            migrationBuilder.DropTable(
                name: "Badges");

            migrationBuilder.DropTable(
                name: "Members");

            migrationBuilder.DropTable(
                name: "Activities");

            migrationBuilder.DropTable(
                name: "ActivityTypes");

            migrationBuilder.DropTable(
                name: "Troops");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "UserAccounts");
        }
    }
}
