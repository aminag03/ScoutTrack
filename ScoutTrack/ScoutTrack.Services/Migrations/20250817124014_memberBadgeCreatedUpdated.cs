using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class memberBadgeCreatedUpdated : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "MemberBadges",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "MemberBadges",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 12, 390, DateTimeKind.Utc).AddTicks(4648));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 12, 390, DateTimeKind.Utc).AddTicks(4711));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 12, 390, DateTimeKind.Utc).AddTicks(4716));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(737));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(751));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(757));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(761));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(766));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(778));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(783));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(787));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(792));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(801));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(807));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(811));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(816));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(820));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(837));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(843));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(847));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(856));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(861));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(865));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(870));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(874));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(879));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(883));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(888));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(893));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(898));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(902));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(906));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(911));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(915));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(920));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(925));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(946));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(951));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(955));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(960));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(965));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(970));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(975));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(979));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(984));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(988));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(993));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(997));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(1002));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(1006));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(1011));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 82, DateTimeKind.Utc).AddTicks(1015));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 400, DateTimeKind.Utc).AddTicks(3340));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 17, 12, 40, 11, 722, DateTimeKind.Utc).AddTicks(2465));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 17, 12, 40, 12, 60, DateTimeKind.Utc).AddTicks(4197));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 11, 400, DateTimeKind.Utc).AddTicks(1989), "$2a$11$sJQQxFzWFEgtIr6Kav2CG.TDUgvO.wpr6mGHa2DIgFneRBQbTd2Ki" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 11, 400, DateTimeKind.Utc).AddTicks(3350), "$2a$11$BDot4xgm2nfpnVo1Z7H0SukhXaleAXCl1Q8rKkUnA47/anQg4PdJ." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 11, 722, DateTimeKind.Utc).AddTicks(2484), "$2a$11$gYYQ5r/VJH0opmhKYljOIeOIA0Q4Ks6DYVWA7nvJa15IKdJ14BcDC" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 12, 60, DateTimeKind.Utc).AddTicks(4216), "$2a$11$jIwfvzejieyAUqeZ1Ny79Of9VNV0MWYb77F7wiA9DUxuprJxwKZly" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 12, 390, DateTimeKind.Utc).AddTicks(4872), "$2a$11$mil2nMAP1YYPr0BHDGeL5O20cTpoD.Qd0gRdy6Bhu..cBajCyqUVm" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 17, 12, 40, 12, 666, DateTimeKind.Utc).AddTicks(1668), "$2a$11$bZdmxWg2apdF8mKSQV6vOOYlXgC2Kr.Vu18BgUylxGEDRtCxPkbM2" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "MemberBadges");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "MemberBadges");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 977, DateTimeKind.Utc).AddTicks(2314));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 977, DateTimeKind.Utc).AddTicks(2345));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 977, DateTimeKind.Utc).AddTicks(2348));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6684));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6691));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6695));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6697));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6699));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6706));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6708));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6710));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6711));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6715));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6717));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6719));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6721));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6723));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6733));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6735));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6737));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6740));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6742));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6744));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6746));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6748));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6750));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6752));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6754));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6756));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6758));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6760));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6762));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6764));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6765));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6767));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6769));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6782));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6784));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6786));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6788));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6790));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6792));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6794));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6796));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6798));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6800));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6802));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6804));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6806));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6807));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6809));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 108, DateTimeKind.Utc).AddTicks(6811));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 320, DateTimeKind.Utc).AddTicks(2845));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 531, DateTimeKind.Utc).AddTicks(693));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 11, 14, 37, 16, 756, DateTimeKind.Utc).AddTicks(5660));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 16, 320, DateTimeKind.Utc).AddTicks(2145), "$2a$11$KDi8/lxq04NEPCVXMJcVbOKx0b2BCB0qfzBUR0wqT5TzT81Z1sJ7y" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 16, 320, DateTimeKind.Utc).AddTicks(2851), "$2a$11$XvvDt0rOklq.ZL02Kz/FvuSRibY0SO09rXvcfwnrsSIi9fFxW48E2" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 16, 531, DateTimeKind.Utc).AddTicks(707), "$2a$11$qScHXYeBqmoibY5GCQnkde2NxMRoJZo7G.PFdbXaWArykaa.VAO5C" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 16, 756, DateTimeKind.Utc).AddTicks(5676), "$2a$11$zMQEmrmnmEFe9wyeqszvneCUMmovNqT1ShaV65HBZ33aVsmZoitOK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 16, 977, DateTimeKind.Utc).AddTicks(2441), "$2a$11$k15c5OB842.FABKUpPLUFODmUwuMsU2uq74fqm7T2dJe9Z7d2qbxK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 11, 14, 37, 17, 166, DateTimeKind.Utc).AddTicks(4659), "$2a$11$0Y0uc.urObwKQuuVGj8tl.muNF0MFO.nTPGGN4CzPgIkoEpYngtba" });
        }
    }
}
