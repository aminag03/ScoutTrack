using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class activityUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "Activities",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LocationName",
                table: "Activities",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "isPrivate",
                table: "Activities",
                type: "bit",
                nullable: false,
                defaultValue: false);

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Cities_CityId",
                table: "Activities");

            migrationBuilder.DropIndex(
                name: "IX_Activities_CityId",
                table: "Activities");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "Activities");

            migrationBuilder.DropColumn(
                name: "LocationName",
                table: "Activities");

            migrationBuilder.DropColumn(
                name: "isPrivate",
                table: "Activities");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 26, 92, DateTimeKind.Utc).AddTicks(9709));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 26, 92, DateTimeKind.Utc).AddTicks(9722));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 26, 92, DateTimeKind.Utc).AddTicks(9725));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(608));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(631));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(633));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(635));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(637));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(642));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(644));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(649));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(650));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(653));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(670));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(672));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(674));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(675));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(688));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(690));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(692));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(694));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(696));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(697));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(699));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(701));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(702));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(704));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(705));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(707));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(709));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(710));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(711));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(713));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(714));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(716));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(717));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(720));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(722));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(723));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(725));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(726));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(729));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(730));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(732));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(733));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(735));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(736));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(738));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(739));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(740));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(742));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 336, DateTimeKind.Utc).AddTicks(744));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 536, DateTimeKind.Utc).AddTicks(5810));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 730, DateTimeKind.Utc).AddTicks(302));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 7, 29, 17, 36, 25, 908, DateTimeKind.Utc).AddTicks(1425));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 25, 536, DateTimeKind.Utc).AddTicks(4919), "$2a$11$LE5W35FHCQky4C1pw.C1h.dkF8rQytLDDTKZJaGhHTkGP4GO7YOie" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 25, 536, DateTimeKind.Utc).AddTicks(5816), "$2a$11$wgKkZC0kozsHmKwviMQSzOCR9WcmMU4xPJQt8EWncWEgX6X7.oihS" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 25, 730, DateTimeKind.Utc).AddTicks(443), "$2a$11$SO9OI3d/tGa2GvmavJgfzeJBx04aHeIgfhUXJiEqHHze66zhBSJF2" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 25, 908, DateTimeKind.Utc).AddTicks(1437), "$2a$11$eXh3KP0vdkS4l5osj/92Buvs6ZprNZYjAKnDELKFF8KOqXKBbxuQ." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 26, 92, DateTimeKind.Utc).AddTicks(9900), "$2a$11$3XjhDWtn14gsrcYvD/Dh7OW0kaso1rOiqxvTNXAduQeHJ/u1cM0nK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 7, 29, 17, 36, 26, 279, DateTimeKind.Utc).AddTicks(5958), "$2a$11$ZC8ow3oZLrqpWIsxBZ6OhepcpVgnKMWiz8K2R.BJZQCfmjAj6EKim" });
        }
    }
}
