using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class activitySummary : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Summary",
                table: "Activities",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 10, 123, DateTimeKind.Utc).AddTicks(942));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 10, 123, DateTimeKind.Utc).AddTicks(951));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 10, 123, DateTimeKind.Utc).AddTicks(953));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(2967));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(2997));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3001));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3003));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3006));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3013));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3015));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3017));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3020));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3024));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3027));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3029));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3031));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3035));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3077));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3080));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3082));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3091));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3095));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3100));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3104));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3109));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3114));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3118));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3123));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3128));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3133));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3138));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3142));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3166));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3172));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3174));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3176));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3183));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3185));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3187));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3208));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3211));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3213));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3216));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3218));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3221));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3224));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3226));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3228));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3231));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3233));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 135, DateTimeKind.Utc).AddTicks(3238));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 328, DateTimeKind.Utc).AddTicks(3078));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 627, DateTimeKind.Utc).AddTicks(4484));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 31, 22, 32, 9, 888, DateTimeKind.Utc).AddTicks(1689));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 9, 328, DateTimeKind.Utc).AddTicks(2240), "$2a$11$RANbnvKm5lQjunEUE3Wrnuos1AHu0cwC.zof4tlQI13l0ZmaHPqIq" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 9, 328, DateTimeKind.Utc).AddTicks(3084), "$2a$11$BkK/LqeL5cQSLCqkIdfL3.3UX4z3Z9hJ3rfap7ErBDG8huPkmI97u" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 9, 627, DateTimeKind.Utc).AddTicks(4524), "$2a$11$.5hwDR57iC1Z0aFZiQeG7OvohK09OPKypbhSt1SJB6rq6/broVhLK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 9, 888, DateTimeKind.Utc).AddTicks(1707), "$2a$11$NsG3x//FgSMrp7w4WYS51OYhd6LHcijzXcnNE5F5dtOjYOE7DlGca" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 10, 123, DateTimeKind.Utc).AddTicks(1010), "$2a$11$8tGwc/K2zBMJ.IXuvLbQju3tzh9TXTCRdupv5KaG.Cd0R65vO88k6" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 31, 22, 32, 10, 354, DateTimeKind.Utc).AddTicks(6963), "$2a$11$h0fJaspEsUu8lMtWaV0OsuuruoPhKlJCSIZVt1fGmBldl0kQaa2Y." });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Summary",
                table: "Activities");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 5, 397, DateTimeKind.Utc).AddTicks(6650));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 5, 397, DateTimeKind.Utc).AddTicks(6662));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 5, 397, DateTimeKind.Utc).AddTicks(6663));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(212));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(236));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(239));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(242));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(244));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(249));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(252));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(255));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(257));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(261));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(263));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(265));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(267));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(270));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(285));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(287));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(289));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(292));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(295));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(298));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(300));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(302));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(304));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(305));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(307));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(309));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(311));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(313));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(314));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(316));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(329));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(330));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(332));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(334));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(336));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(337));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(339));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(340));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(342));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(344));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(345));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(347));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(348));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(350));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(352));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(354));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(357));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(358));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 719, DateTimeKind.Utc).AddTicks(360));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 54, 4, 891, DateTimeKind.Utc).AddTicks(6575));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 54, 5, 63, DateTimeKind.Utc).AddTicks(2343));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 54, 5, 236, DateTimeKind.Utc).AddTicks(8954));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 4, 891, DateTimeKind.Utc).AddTicks(5748), "$2a$11$X3IL7Axq4CInM7W7YuXqYO9J5lChn/5VIvEG74QBdhmtLHyZUSHLK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 4, 891, DateTimeKind.Utc).AddTicks(6585), "$2a$11$5.NmhTf2zTDAwwKHmKyH9.ltTJTRWvNqm9CDVz22A8yKc/lHIhU5." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 5, 63, DateTimeKind.Utc).AddTicks(2356), "$2a$11$nPctoUDH8gT.RR4i6brmC.Umx1KFx3DWVGgIxYissL0TZ8dO9xhAS" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 5, 236, DateTimeKind.Utc).AddTicks(8965), "$2a$11$K9ccmgmhRg/KUejioPICV.MxeoC52iV/MXebkbR/35ahLoLEH5i0O" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 5, 397, DateTimeKind.Utc).AddTicks(6726), "$2a$11$R.YgJ5WmG7JKxUNOIM/8xuhyV28FA.A6E44wnt3Vc.sqbwUJhF0Gq" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 54, 5, 560, DateTimeKind.Utc).AddTicks(2237), "$2a$11$z6i8hhjU18XoogQgONMLseQatvYb81D8iJxnWrVopWegiiAyeO5Wu" });
        }
    }
}
