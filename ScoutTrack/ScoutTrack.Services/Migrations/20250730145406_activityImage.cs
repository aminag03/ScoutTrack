using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class activityImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImagePath",
                table: "Activities",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImagePath",
                table: "Activities");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 5, 373, DateTimeKind.Utc).AddTicks(5613));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 5, 373, DateTimeKind.Utc).AddTicks(5783));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 5, 373, DateTimeKind.Utc).AddTicks(5788));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1916));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1934));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1936));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1938));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1940));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1955));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1957));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1959));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1960));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1963));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1964));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1966));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1968));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1969));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1983));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1985));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1986));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1990));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1991));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1993));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1995));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1996));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1998));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(1999));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2001));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2003));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2004));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2006));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2007));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2009));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2011));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2012));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2014));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2016));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2018));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2019));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2021));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2023));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2024));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2026));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2028));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2030));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2032));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2034));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2035));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2037));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2038));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2040));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 463, DateTimeKind.Utc).AddTicks(2042));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 659, DateTimeKind.Utc).AddTicks(4425));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 30, 4, 858, DateTimeKind.Utc).AddTicks(5687));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 30, 14, 30, 5, 56, DateTimeKind.Utc).AddTicks(6818));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 4, 659, DateTimeKind.Utc).AddTicks(3193), "$2a$11$1zNTpqiybCZwG9x5LVT/5uxQEVWO8X9yHQybsZkL6JCjIuoaBtIEu" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 4, 659, DateTimeKind.Utc).AddTicks(4436), "$2a$11$gA1Fmp7hYj9DjfRzWc9GxO8sdVinv.bKMisKM44fnZ9CpBH5SIaG2" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 4, 858, DateTimeKind.Utc).AddTicks(5698), "$2a$11$GeVhGekvjLl3TSWWpHIfruyQ6xXY8N6vUGuqIBHjSI4a1aABJ32Eq" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 5, 56, DateTimeKind.Utc).AddTicks(6842), "$2a$11$AGPhGvpZ3AagLDp0oUHPk.n7UYEQHdQZ.W27Vac4bZXlpyoWbs0Pu" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 5, 373, DateTimeKind.Utc).AddTicks(6162), "$2a$11$JS11E1d57P19YdmHTNmgJOzSIpeyt42aU0gb06pL2kNLXRXuGwJ.S" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 30, 14, 30, 5, 779, DateTimeKind.Utc).AddTicks(5501), "$2a$11$aw//ojlcBmTQjp5RJEuCaO6XdI5vcpc6o0XuhR3zTW7SfJOX6TrF." });
        }
    }
}
