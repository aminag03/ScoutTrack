using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class notification : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_UserAccounts_UserAccountId",
                table: "Notifications");

            migrationBuilder.RenameColumn(
                name: "UserAccountId",
                table: "Notifications",
                newName: "SenderId");

            migrationBuilder.RenameIndex(
                name: "IX_Notifications_UserAccountId",
                table: "Notifications",
                newName: "IX_Notifications_SenderId");

            migrationBuilder.AddColumn<int>(
                name: "ReceiverId",
                table: "Notifications",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 24, 87, DateTimeKind.Utc).AddTicks(528));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 24, 87, DateTimeKind.Utc).AddTicks(556));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 24, 87, DateTimeKind.Utc).AddTicks(559));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1916));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1926));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1929));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1930));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1932));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1938));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1939));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1941));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1943));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1946));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1948));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1950));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1951));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1953));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1966));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1968));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1969));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1972));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1974));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1976));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1977));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1979));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1980));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1982));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1984));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1985));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1987));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1988));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1990));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1992));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1993));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1995));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1996));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(1999));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2001));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2002));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2004));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2005));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2007));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2009));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2010));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2021));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2024));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2025));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2027));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2029));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2030));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2032));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 400, DateTimeKind.Utc).AddTicks(2033));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 569, DateTimeKind.Utc).AddTicks(8239));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 745, DateTimeKind.Utc).AddTicks(3966));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 29, 21, 12, 23, 916, DateTimeKind.Utc).AddTicks(1199));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 23, 569, DateTimeKind.Utc).AddTicks(7055), "$2a$11$4UrNusab8kdJfLhyjJH92ue/sj5vROQIVp4ZxvXXpoO7aPJRkpgJG" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 23, 569, DateTimeKind.Utc).AddTicks(8248), "$2a$11$PeOKPk6X153b9G7AUh4tMOj42C1E3BNBVEfpm6MrzP0Tv0065FLE." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 23, 745, DateTimeKind.Utc).AddTicks(3999), "$2a$11$fKFbv7Gf3saBQAHtMmke3uxPaieayZDDyVEbyf.xl32hy01uAbU6." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 23, 916, DateTimeKind.Utc).AddTicks(1212), "$2a$11$lclvoQ5fEDbt6Ruo49IO0.zg2h6BVFMCqgQgvpHKNo9BlOORqaL7a" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 24, 87, DateTimeKind.Utc).AddTicks(633), "$2a$11$CS1t2Gcwy4yQTK1Gwa49nOVCEzamk2isRAt2EWpvplf3EizBRtoOK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 29, 21, 12, 24, 273, DateTimeKind.Utc).AddTicks(2720), "$2a$11$AQHOWsPuiIZ18BnOfSAbt.H.NJkSim8ZhZWxa2YPENi6Pca8ETH.C" });

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_ReceiverId",
                table: "Notifications",
                column: "ReceiverId");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_UserAccounts_ReceiverId",
                table: "Notifications",
                column: "ReceiverId",
                principalTable: "UserAccounts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_UserAccounts_SenderId",
                table: "Notifications",
                column: "SenderId",
                principalTable: "UserAccounts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_UserAccounts_ReceiverId",
                table: "Notifications");

            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_UserAccounts_SenderId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_ReceiverId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "ReceiverId",
                table: "Notifications");

            migrationBuilder.RenameColumn(
                name: "SenderId",
                table: "Notifications",
                newName: "UserAccountId");

            migrationBuilder.RenameIndex(
                name: "IX_Notifications_SenderId",
                table: "Notifications",
                newName: "IX_Notifications_UserAccountId");

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

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_UserAccounts_UserAccountId",
                table: "Notifications",
                column: "UserAccountId",
                principalTable: "UserAccounts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
