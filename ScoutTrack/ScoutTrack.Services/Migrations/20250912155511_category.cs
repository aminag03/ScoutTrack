using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class category : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "Members",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    MinAge = table.Column<int>(type: "int", nullable: false),
                    MaxAge = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

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
                table: "Members",
                keyColumn: "Id",
                keyValue: 5,
                column: "CategoryId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Members",
                keyColumn: "Id",
                keyValue: 6,
                column: "CategoryId",
                value: null);

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

            migrationBuilder.CreateIndex(
                name: "IX_Members_CategoryId",
                table: "Members",
                column: "CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Members_Categories_CategoryId",
                table: "Members",
                column: "CategoryId",
                principalTable: "Categories",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Members_Categories_CategoryId",
                table: "Members");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropIndex(
                name: "IX_Members_CategoryId",
                table: "Members");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "Members");

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
    }
}
