using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class categoryCreatedUpdatedAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Categories",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Categories",
                type: "datetime2",
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

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CreatedAt", "Description", "MaxAge", "MinAge", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4750), "Najmlađi izviđači do 10 godina", 10, 0, "Poletarac", null },
                    { 2, new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4801), "Mlađi izviđači od 11 do 14 godina", 14, 11, "Mlađi izviđač", null },
                    { 3, new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4812), "Stariji izviđači od 15 do 19 godina", 19, 15, "Stariji izviđač", null },
                    { 4, new DateTime(2025, 9, 12, 18, 27, 39, 569, DateTimeKind.Local).AddTicks(4821), "Brđani od 20 godina i stariji", 100, 20, "Brđan", null }
                });

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
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 37, 960, DateTimeKind.Local).AddTicks(1787), "$2a$11$YmNiJq7Uw9LWjuNCuUmD9OnWrF2Y8h02VRKapJhoQnji3j5.NV2Ra" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 37, 960, DateTimeKind.Local).AddTicks(2682), "$2a$11$HvZbDd2SyGzfkJiMT96nUOdeX7VyDEGdBrXaQGIoVFnlseqFSHgQW" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 293, DateTimeKind.Local).AddTicks(4728), "$2a$11$Jcb9WoWcMTJrnlINBomcUu2zfJiLNQD5UQqS9L/tke1RkrgG5iFKu" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 633, DateTimeKind.Local).AddTicks(9758), "$2a$11$/.F0i/OgG9P6HSbsW/HT4u3OBsZJEtewGrd5EnPLt8fm7r5aVv19e" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 38, 914, DateTimeKind.Local).AddTicks(8067), "$2a$11$Y8dqRq6AQki3NQ56UuAmGukWJw1/TgTTe/ERugM4pD9WhgianC.km" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 18, 27, 39, 237, DateTimeKind.Local).AddTicks(8265), "$2a$11$8WlsstJu85dLoH8VroO0QOWGWX0fG3GMCnNxpWzfvITwX3dD4baKW" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Categories");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 10, 172, DateTimeKind.Local).AddTicks(1543));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 10, 172, DateTimeKind.Local).AddTicks(1647));

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 10, 172, DateTimeKind.Local).AddTicks(1652));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8619));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8805));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8815));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8904));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8913));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8933));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8941));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8949));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8965));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8976));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8985));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(8993));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9001));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9009));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9045));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9053));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9085));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9106));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9175));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9184));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9192));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9200));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9207));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9215));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9223));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9231));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9239));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9247));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9254));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9262));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9270));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9326));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9340));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9358));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9367));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9417));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9435));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9444));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9453));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9461));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9469));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9477));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9486));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9494));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9503));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9511));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9519));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9527));

            migrationBuilder.UpdateData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 143, DateTimeKind.Local).AddTicks(9535));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 2,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 480, DateTimeKind.Local).AddTicks(9154));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 3,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 718, DateTimeKind.Local).AddTicks(8961));

            migrationBuilder.UpdateData(
                table: "Troops",
                keyColumn: "Id",
                keyValue: 4,
                column: "FoundingDate",
                value: new DateTime(2025, 9, 12, 17, 55, 9, 952, DateTimeKind.Local).AddTicks(1788));

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 9, 480, DateTimeKind.Local).AddTicks(8126), "$2a$11$U7HYWDvqkLwqnzxJdr4KiefgRTyS.txc4jqg8ZnEH.JNM9MfpoClC" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 9, 480, DateTimeKind.Local).AddTicks(9172), "$2a$11$io6vM4PynRL9hJOswq8Dm.8vGRRkjzR5jFS1cnH5rGqglLu6g8PkK" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 9, 718, DateTimeKind.Local).AddTicks(9191), "$2a$11$aceeAy1iYGBerfvCT5a7ZOL4jS2W3yu.9OLb2lAU.dWlCkDYfwlCe" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 9, 952, DateTimeKind.Local).AddTicks(1868), "$2a$11$IKEFWB4Y0OcoyUEsN1nQ8OPDap9FX0Q/zLJQ13eExeuskTUV4VH6." });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 10, 172, DateTimeKind.Local).AddTicks(1753), "$2a$11$INleVItD7pqgQn0NnWROBONKJAkqa90r3zbwwYfG1RYJ0pGSwZFTO" });

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2025, 9, 12, 17, 55, 10, 411, DateTimeKind.Local).AddTicks(6205), "$2a$11$KvK9Dea154EJbnZMYpZdRu4JUJOxWJandY/FmhyPAwdKOJwW97Va." });
        }
    }
}
