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
                    ActivityTypeId = table.Column<int>(type: "int", nullable: false)
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
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MemberId1 = table.Column<int>(type: "int", nullable: true)
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
                    table.ForeignKey(
                        name: "FK_ActivityRegistrations_Members_MemberId1",
                        column: x => x.MemberId1,
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
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    MemberId1 = table.Column<int>(type: "int", nullable: true)
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
                    table.ForeignKey(
                        name: "FK_MemberBadges_Members_MemberId1",
                        column: x => x.MemberId1,
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
                    { 1, new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4980), "Basic first aid skills", "", "First Aid", null },
                    { 2, new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4994), "Learn how to safely handle fire", "", "Fire Safety", null },
                    { 3, new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4996), "Orientation and map skills", "", "Map Reading", null }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "CreatedAt", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(151), "Banovići", null },
                    { 2, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(167), "Banja Luka", null },
                    { 3, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(168), "Bihać", null },
                    { 4, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(169), "Bijeljina", null },
                    { 5, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(170), "Bileća", null },
                    { 6, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(173), "Bosanski Brod", null },
                    { 7, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(174), "Bosanska Dubica", null },
                    { 8, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(175), "Bosanska Gradiška", null },
                    { 9, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(176), "Bosansko Grahovo", null },
                    { 10, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(178), "Bosanska Krupa", null },
                    { 11, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(178), "Bosanski Novi", null },
                    { 12, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(179), "Bosanski Petrovac", null },
                    { 13, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(180), "Bosanski Šamac", null },
                    { 14, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(181), "Bratunac", null },
                    { 15, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(182), "Brčko", null },
                    { 16, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(183), "Breza", null },
                    { 17, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(184), "Bugojno", null },
                    { 18, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(189), "Busovača", null },
                    { 19, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(190), "Bužim", null },
                    { 20, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(201), "Cazin", null },
                    { 21, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(202), "Čajniče", null },
                    { 22, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(203), "Čapljina", null },
                    { 23, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(205), "Čelić", null },
                    { 24, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(206), "Čelinac", null },
                    { 25, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(207), "Čitluk", null },
                    { 26, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(208), "Derventa", null },
                    { 27, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(209), "Doboj", null },
                    { 28, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(210), "Donji Vakuf", null },
                    { 29, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(211), "Drvar", null },
                    { 30, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(212), "Foča", null },
                    { 31, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(213), "Fojnica", null },
                    { 32, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(214), "Gacko", null },
                    { 33, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(215), "Glamoč", null },
                    { 34, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(217), "Goražde", null },
                    { 35, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(217), "Gornji Vakuf", null },
                    { 36, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(218), "Gračanica", null },
                    { 37, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(219), "Gradačac", null },
                    { 38, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(220), "Grude", null },
                    { 39, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(221), "Hadžići", null },
                    { 40, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(222), "Han-Pijesak", null },
                    { 41, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(222), "Hlivno", null },
                    { 42, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(224), "Ilijaš", null },
                    { 43, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(224), "Jablanica", null },
                    { 44, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(225), "Jajce", null },
                    { 45, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(226), "Kakanj", null },
                    { 46, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(227), "Kalesija", null },
                    { 47, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(228), "Kalinovik", null },
                    { 48, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(229), "Kiseljak", null },
                    { 49, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(229), "Kladanj", null },
                    { 50, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(230), "Ključ", null },
                    { 51, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(231), "Konjic", null },
                    { 52, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(232), "Kotor-Varoš", null },
                    { 53, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(233), "Kreševo", null },
                    { 54, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(234), "Kupres", null },
                    { 55, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(234), "Laktaši", null },
                    { 56, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(235), "Lopare", null },
                    { 57, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(236), "Lukavac", null },
                    { 58, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(237), "Ljubinje", null },
                    { 59, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(238), "Ljubuški", null },
                    { 60, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(239), "Maglaj", null },
                    { 61, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(240), "Modriča", null },
                    { 62, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(240), "Mostar", null },
                    { 63, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(241), "Mrkonjić-Grad", null },
                    { 64, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(242), "Neum", null },
                    { 65, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(243), "Nevesinje", null },
                    { 66, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(245), "Novi Travnik", null },
                    { 67, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(246), "Odžak", null },
                    { 68, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(247), "Olovo", null },
                    { 69, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(254), "Orašje", null },
                    { 70, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(255), "Pale", null },
                    { 71, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(256), "Posušje", null },
                    { 72, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(256), "Prijedor", null },
                    { 73, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(257), "Prnjavor", null },
                    { 74, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(258), "Prozor", null },
                    { 75, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(259), "Rogatica", null },
                    { 76, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(260), "Rudo", null },
                    { 77, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(261), "Sanski Most", null },
                    { 78, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(261), "Sarajevo", null },
                    { 79, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(262), "Skender-Vakuf", null },
                    { 80, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(263), "Sokolac", null },
                    { 81, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(264), "Srbac", null },
                    { 82, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(265), "Srebrenica", null },
                    { 83, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(265), "Srebrenik", null },
                    { 84, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(266), "Stolac", null },
                    { 85, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(267), "Šekovići", null },
                    { 86, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(268), "Šipovo", null },
                    { 87, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(269), "Široki Brijeg", null },
                    { 88, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(270), "Teslić", null },
                    { 89, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(270), "Tešanj", null },
                    { 90, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(271), "Tomislav-Grad", null },
                    { 91, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(272), "Travnik", null },
                    { 92, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(273), "Trebinje", null },
                    { 93, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(274), "Trnovo", null },
                    { 94, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(275), "Tuzla", null },
                    { 95, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(275), "Ugljevik", null },
                    { 96, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(276), "Vareš", null },
                    { 97, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(277), "Velika Kladuša", null },
                    { 98, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(278), "Visoko", null },
                    { 99, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(279), "Višegrad", null },
                    { 100, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(280), "Vitez", null },
                    { 101, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(281), "Vlasenica", null },
                    { 102, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(281), "Zavidovići", null },
                    { 103, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(282), "Zenica", null },
                    { 104, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(283), "Zvornik", null },
                    { 105, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(284), "Žepa", null },
                    { 106, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(285), "Žepče", null },
                    { 107, new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(285), "Živinice", null }
                });

            migrationBuilder.InsertData(
                table: "UserAccounts",
                columns: new[] { "Id", "CreatedAt", "Email", "IsActive", "LastLoginAt", "PasswordHash", "Role", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 1, 21, 23, 9, 560, DateTimeKind.Utc).AddTicks(4740), "admin@scouttrack.ba", true, null, "$2a$11$m/H5WvK1f/mdWm4EHXCxo.LXpL84P0290VRdkn4nKaGTHDbyuctfa", 0, null, "admin" },
                    { 2, new DateTime(2025, 7, 1, 21, 23, 9, 560, DateTimeKind.Utc).AddTicks(6920), "troopbl@scouttrack.ba", true, null, "$2a$11$w5mNtaFCn32T4f1acYb6d.IzK6cm0xArecXVX/OGgl97sOJ8LojdG", 1, null, "troopbl" },
                    { 3, new DateTime(2025, 7, 1, 21, 23, 9, 744, DateTimeKind.Utc).AddTicks(217), "troopsarajevo@scouttrack.ba", true, null, "$2a$11$BmSHU1rZZakPN3ufcTae0e6h0oDPOPxpo0NC31mgLTMA4390H8YlO", 1, null, "troopsarajevo" },
                    { 4, new DateTime(2025, 7, 1, 21, 23, 9, 908, DateTimeKind.Utc).AddTicks(2914), "troopmostar@scouttrack.ba", true, null, "$2a$11$jnsvenNpZJD5GDAMpuqcbuSmeHcy1NJMK.3GsiwI9VD3WAOq7yJKm", 1, null, "troopmostar" },
                    { 5, new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(5062), "scout1@scouttrack.ba", true, null, "$2a$11$3wngNDujunTqbZ3Vor7uTOT.k.2TU6XjJudtZuik1HMfHujl9kIIO", 2, null, "scout1" },
                    { 6, new DateTime(2025, 7, 1, 21, 23, 10, 257, DateTimeKind.Utc).AddTicks(2627), "scout2@scouttrack.ba", true, null, "$2a$11$2Rl3vJiguygWxhzcIh1LwesgnZP/tOnYlG7pN1V1iSC9/tBRDoU/q", 2, null, "scout2" }
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
                    { 3, 76, "", 0.0, "", 0.0, "Troop Sarajevo" },
                    { 4, 63, "", 0.0, "", 0.0, "Troop Mostar" }
                });

            migrationBuilder.InsertData(
                table: "Members",
                columns: new[] { "Id", "BirthDate", "CityId", "ContactPhone", "FirstName", "Gender", "LastName", "ProfilePictureUrl", "TroopId" },
                values: new object[,]
                {
                    { 5, new DateTime(2005, 5, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "", "John", 0, "Doe", "", 2 },
                    { 6, new DateTime(2003, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 76, "", "Jane", 1, "Doe", "", 3 }
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
                name: "IX_ActivityEquipments_ActivityId_EquipmentId",
                table: "ActivityEquipments",
                columns: new[] { "ActivityId", "EquipmentId" },
                unique: true);

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
                name: "IX_ActivityRegistrations_MemberId1",
                table: "ActivityRegistrations",
                column: "MemberId1");

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
                name: "IX_MemberBadges_MemberId1",
                table: "MemberBadges",
                column: "MemberId1");

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
