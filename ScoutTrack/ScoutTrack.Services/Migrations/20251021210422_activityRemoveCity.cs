using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class activityRemoveCity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Cities_CityId",
                table: "Activities");

            migrationBuilder.DropIndex(
                name: "IX_Activities_CityId",
                table: "Activities");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "UserAccounts");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "Activities");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 738, DateTimeKind.Local).AddTicks(2248));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 738, DateTimeKind.Local).AddTicks(2341));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 738, DateTimeKind.Local).AddTicks(2345));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 21, 149, DateTimeKind.Local).AddTicks(8764));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 21, 149, DateTimeKind.Local).AddTicks(8828));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 21, 149, DateTimeKind.Local).AddTicks(8836));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 21, 149, DateTimeKind.Local).AddTicks(8843));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3528));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3612));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3617));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3621));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3624));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3631));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3638));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3642));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3645));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3661));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3702));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3706));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3709));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3712));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3715));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3718));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3721));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3726));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3729));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3732));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3735));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3738));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3742));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3745));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3748));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3751));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3754));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3757));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3760));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3764));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3767));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3770));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3840));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3845));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3848));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3852));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3856));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3859));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3863));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3866));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3869));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3872));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3875));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3878));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3881));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3885));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3888));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3891));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 21, 23, 4, 19, 903, DateTimeKind.Local).AddTicks(3894));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 96, DateTimeKind.Local).AddTicks(6694));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 301, DateTimeKind.Local).AddTicks(7799));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 10, 21, 23, 4, 20, 513, DateTimeKind.Local).AddTicks(9127));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 96, DateTimeKind.Local).AddTicks(5833), "$2a$11$aArEErOVB6ejfH8j1FoqIeoSjZlGvXt52N2aDa8g2jlmytNdKNYyu" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 96, DateTimeKind.Local).AddTicks(6716), "$2a$11$EdMUwDFN5PI3fI3fCKCoC.EmPMJaPZX7/ZIw.FesLsqMjxk8yd.8e" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 301, DateTimeKind.Local).AddTicks(7873), "$2a$11$vNvBB9JRV5gHvD1kmS0U..AYLYV7Az4e3zUIhWFfGOZAe3PJrarEa" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 513, DateTimeKind.Local).AddTicks(9192), "$2a$11$Lx8S3Y1qY9MxacyZvRXtwe9swiSLXfgjr85dYSGAJ9G.PYDuNRWTq" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 738, DateTimeKind.Local).AddTicks(2458), "$2a$11$sPI6QLD4/r.i6JVyCTGKge7dG2PqILorv5vXpOdEZ4JhVrXDtOIm." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 10, 21, 23, 4, 20, 947, DateTimeKind.Local).AddTicks(9085), "$2a$11$MeYjmwdMShU7j2d6bJzJzuyzxrPfvkC10EH9G8bZj0TAsKZishLFu" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "UserAccounts",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "Activities",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 38, 914, DateTimeKind.Local).AddTicks(7781));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 38, 914, DateTimeKind.Local).AddTicks(7919));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 38, 914, DateTimeKind.Local).AddTicks(7926));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4750));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4801));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4812));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4821));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3231));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3496));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3506));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3513));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3544));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3559));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3583));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3590));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3596));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3612));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3668));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3676));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3683));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3690));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3700));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3723));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3730));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3740));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3747));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3754));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3761));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3768));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3775));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3783));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3789));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3797));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3804));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3811));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3818));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3825));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3832));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3838));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3845));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3854));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3863));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3870));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3877));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3884));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3891));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3898));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3905));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3912));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3919));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3926));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3933));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3940));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3946));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3953));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 669, DateTimeKind.Local).AddTicks(3960));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 18, 27, 37, 960, DateTimeKind.Local).AddTicks(2667));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 18, 27, 38, 293, DateTimeKind.Local).AddTicks(4664));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 18, 27, 38, 633, DateTimeKind.Local).AddTicks(9659));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 37, 960, DateTimeKind.Local).AddTicks(1787), true, "$2a$11$YmNiJq7Uw9LWjuNCuUmD9OnWrF2Y8h02VRKapJhoQnji3j5.NV2Ra" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 37, 960, DateTimeKind.Local).AddTicks(2682), true, "$2a$11$HvZbDd2SyGzfkJiMT96nUOdeX7VyDEGdBrXaQGIoVFnlseqFSHgQW" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 293, DateTimeKind.Local).AddTicks(4728), true, "$2a$11$Jcb9WoWcMTJrnlINBomcUu2zfJiLNQD5UQqS9L/tke1RkrgG5iFKu" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 633, DateTimeKind.Local).AddTicks(9758), true, "$2a$11$/.F0i/OgG9P6HSbsW/HT4u3OBsZJEtewGrd5EnPLt8fm7r5aVv19e" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 914, DateTimeKind.Local).AddTicks(8067), true, "$2a$11$Y8dqRq6AQki3NQ56UuAmGukWJw1/TgTTe/ERugM4pD9WhgianC.km" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "IsActive", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 39, 237, DateTimeKind.Local).AddTicks(8265), true, "$2a$11$8WlsstJu85dLoH8VroO0QOWGWX0fG3GMCnNxpWzfvITwX3dD4baKW" });

            migrationBuilder.CreateIndex(
                name: "IX_Activities_CityId",
                table: "Activities",
                column: "CityId");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Cities_CityId",
                table: "Activities",
                column: "CityId",
                principalTable: "Cities",
                principalColumn: "Id");
        }
    }
}
