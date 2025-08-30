using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class notificationSender : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "SenderId",
                table: "Notifications",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 16, 126, DateTimeKind.Local).AddTicks(3363));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 16, 126, DateTimeKind.Local).AddTicks(3465));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 16, 126, DateTimeKind.Local).AddTicks(3470));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(5942));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6012));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6017));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6051));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6055));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6063));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6067));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6071));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6075));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6083));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6088));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6094));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6098));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6102));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6111));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6115));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6119));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6127));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6166));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6171));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6175));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6179));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6183));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6187));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6192));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6196));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6200));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6204));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6208));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6212));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6216));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6221));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6225));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6240));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6245));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6249));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6253));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6257));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6261));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6265));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6269));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6273));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6278));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6282));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6286));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6290));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6294));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6298));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 374, DateTimeKind.Local).AddTicks(6302));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 553, DateTimeKind.Local).AddTicks(8572));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 740, DateTimeKind.Local).AddTicks(8398));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 8, 30, 17, 28, 15, 942, DateTimeKind.Local).AddTicks(9940));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 15, 553, DateTimeKind.Local).AddTicks(7733), "$2a$11$LU7J2RdoKdKPrDm5RVlAYesFyOT0Sndmn56Yghs3tZ1bhGRyX/axe" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 15, 553, DateTimeKind.Local).AddTicks(8590), "$2a$11$0lYtB7SNbuvSE9nAHdJwUeEsWrnWmGLjw1VA7h.mW4bjy.9MT3WyG" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 15, 740, DateTimeKind.Local).AddTicks(8470), "$2a$11$ClfBWJPgWoggR0PMlCW28ObRVsk7iakXyvtk.XApElwbHV8WWGjwO" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 15, 943, DateTimeKind.Local).AddTicks(27), "$2a$11$7z9kiR84/xMdroHXcW2EXOdV9fJxUQNjXoA78K8DV0Vj/mhXR8JLa" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 16, 126, DateTimeKind.Local).AddTicks(3567), "$2a$11$xXqMKZ6/Kny2/vlfYRAUjeFYu9GbT39DfnVaBbO3Egdzmdl1r4Q4i" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 8, 30, 17, 28, 16, 307, DateTimeKind.Local).AddTicks(620), "$2a$11$b/2hWRQGuM9zOyEs4p/aFedQc6qEAjtEwl5t3WO8jCbD4Z2P1mnF." });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "SenderId",
                table: "Notifications",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

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
        }
    }
}
