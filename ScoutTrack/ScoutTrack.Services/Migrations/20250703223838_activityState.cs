using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class activityState : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ActivityState",
                table: "Activities",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 971, DateTimeKind.Utc).AddTicks(9491));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 971, DateTimeKind.Utc).AddTicks(9519));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 971, DateTimeKind.Utc).AddTicks(9521));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6268));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6277));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6290));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6291));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6292));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6296));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6297));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6298));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6299));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6301));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6302));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6303));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6304));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6305));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6305));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6306));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6307));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6314));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6315));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6316));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6317));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6318));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6319));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6320));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6321));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6322));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6323));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6324));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6325));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6326));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6326));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6327));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6328));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6331));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6331));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6332));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6333));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6334));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6335));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6336));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6337));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6338));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6339));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6340));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6341));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6341));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6342));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6343));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6344));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6345));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6346));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 52,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6347));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 53,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6348));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 54,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6348));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 55,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6358));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 56,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6360));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 57,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6361));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 58,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6362));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 59,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6363));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 60,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6364));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 61,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6365));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 62,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6365));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 63,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6366));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 64,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6367));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 65,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6368));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 66,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6370));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 67,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6372));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 68,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6373));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 69,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6373));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 70,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6374));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 71,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6375));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 72,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6376));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 73,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6377));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 74,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6378));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 75,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6379));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 76,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6380));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 77,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6380));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 78,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6381));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 79,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6382));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 80,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6383));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 81,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6384));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 82,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6385));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 83,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6386));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 84,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6386));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 85,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6387));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 86,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6388));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 87,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6389));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 88,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6390));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 89,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6391));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 90,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6392));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 91,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6392));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 92,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6394));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 93,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6394));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 94,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6396));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 95,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6397));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 96,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6397));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 97,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6398));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 98,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6399));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 99,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6400));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 100,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6401));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 101,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6402));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 102,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6403));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 103,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6404));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 104,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6404));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 105,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6405));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 106,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6406));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 107,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 3, 22, 38, 36, 358, DateTimeKind.Utc).AddTicks(6407));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 36, 506, DateTimeKind.Utc).AddTicks(1964), "$2a$11$B3UCayAvm0q2bz4PE64lB.aeuMIxtOOW.zCUhNlVjfppqtit9Gd9e" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 36, 506, DateTimeKind.Utc).AddTicks(2754), "$2a$11$cvyOYyPlHGYbzBI1bZIhzOx/blh3YMJGwxQcf/YgW6.LxssERipTq" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 36, 670, DateTimeKind.Utc).AddTicks(3217), "$2a$11$r967Lz7OCUAt5ITui4wpUeINX29GOj8dCjXqZh.9gXyk8yAjo84G2" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 36, 823, DateTimeKind.Utc).AddTicks(3674), "$2a$11$G2ZgoKLq9nojGZXjPFwwRuBS1gDgwiWWMOdTUp1iFRTO2nHBnK/7." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 36, 971, DateTimeKind.Utc).AddTicks(9590), "$2a$11$kCOeNJ2CaTLSQt0V0bk4lOtPdnPZvS6p5lXp5W0p39INVq6lVLlSm" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 3, 22, 38, 37, 121, DateTimeKind.Utc).AddTicks(3818), "$2a$11$wP9okmW1twqvdFqSUZELV.hkmlUsZSnruzccnixmAOjavgxjnY8cm" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ActivityState",
                table: "Activities");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4980));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4994));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(4996));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(151));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(167));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(168));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(169));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(170));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(173));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(174));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(175));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(176));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(178));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(178));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(179));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(180));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(181));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(182));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(183));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(184));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(189));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(190));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(201));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(202));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(203));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(205));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(206));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(207));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(208));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(209));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(210));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(211));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(212));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(213));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(214));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(215));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(217));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(217));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(218));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(219));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(220));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(221));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(222));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(222));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(224));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(224));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(225));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(226));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(227));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(228));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(229));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(229));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(230));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(231));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 52,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(232));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 53,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(233));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 54,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(234));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 55,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(234));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 56,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(235));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 57,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(236));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 58,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(237));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 59,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(238));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 60,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(239));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 61,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(240));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 62,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(240));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 63,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(241));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 64,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(242));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 65,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(243));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 66,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(245));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 67,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(246));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 68,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(247));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 69,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(254));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 70,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(255));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 71,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(256));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 72,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(256));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 73,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(257));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 74,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(258));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 75,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(259));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 76,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(260));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 77,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(261));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 78,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(261));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 79,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(262));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 80,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(263));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 81,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(264));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 82,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(265));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 83,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(265));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 84,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(266));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 85,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(267));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 86,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(268));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 87,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(269));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 88,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(270));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 89,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(270));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 90,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(271));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 91,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(272));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 92,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(273));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 93,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(274));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 94,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(275));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 95,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(275));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 96,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(276));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 97,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(277));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 98,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(278));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 99,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(279));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 100,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(280));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 101,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(281));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 102,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(281));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 103,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(282));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 104,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(283));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 105,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(284));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 106,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(285));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 107,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 1, 21, 23, 9, 395, DateTimeKind.Utc).AddTicks(285));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 9, 560, DateTimeKind.Utc).AddTicks(4740), "$2a$11$m/H5WvK1f/mdWm4EHXCxo.LXpL84P0290VRdkn4nKaGTHDbyuctfa" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 9, 560, DateTimeKind.Utc).AddTicks(6920), "$2a$11$w5mNtaFCn32T4f1acYb6d.IzK6cm0xArecXVX/OGgl97sOJ8LojdG" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 9, 744, DateTimeKind.Utc).AddTicks(217), "$2a$11$BmSHU1rZZakPN3ufcTae0e6h0oDPOPxpo0NC31mgLTMA4390H8YlO" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 9, 908, DateTimeKind.Utc).AddTicks(2914), "$2a$11$jnsvenNpZJD5GDAMpuqcbuSmeHcy1NJMK.3GsiwI9VD3WAOq7yJKm" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 10, 91, DateTimeKind.Utc).AddTicks(5062), "$2a$11$3wngNDujunTqbZ3Vor7uTOT.k.2TU6XjJudtZuik1HMfHujl9kIIO" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 1, 21, 23, 10, 257, DateTimeKind.Utc).AddTicks(2627), "$2a$11$2Rl3vJiguygWxhzcIh1LwesgnZP/tOnYlG7pN1V1iSC9/tBRDoU/q" });
        }
    }
}
