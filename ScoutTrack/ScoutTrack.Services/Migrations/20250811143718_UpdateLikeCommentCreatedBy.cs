using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateLikeCommentCreatedBy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Comments_Members_MemberId",
                table: "Comments");

            migrationBuilder.DropForeignKey(
                name: "FK_Likes_Members_MemberId",
                table: "Likes");

            migrationBuilder.RenameColumn(
                name: "MemberId",
                table: "Likes",
                newName: "CreatedById");

            migrationBuilder.RenameIndex(
                name: "IX_Likes_PostId_MemberId",
                table: "Likes",
                newName: "IX_Likes_PostId_CreatedById");

            migrationBuilder.RenameIndex(
                name: "IX_Likes_MemberId",
                table: "Likes",
                newName: "IX_Likes_CreatedById");

            migrationBuilder.RenameColumn(
                name: "MemberId",
                table: "Comments",
                newName: "CreatedById");

            migrationBuilder.RenameIndex(
                name: "IX_Comments_PostId_MemberId_CreatedAt",
                table: "Comments",
                newName: "IX_Comments_PostId_CreatedById_CreatedAt");

            migrationBuilder.RenameIndex(
                name: "IX_Comments_MemberId",
                table: "Comments",
                newName: "IX_Comments_CreatedById");

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

            migrationBuilder.AddForeignKey(
                name: "FK_Comments_UserAccounts_CreatedById",
                table: "Comments",
                column: "CreatedById",
                principalTable: "UserAccounts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Likes_UserAccounts_CreatedById",
                table: "Likes",
                column: "CreatedById",
                principalTable: "UserAccounts",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Comments_UserAccounts_CreatedById",
                table: "Comments");

            migrationBuilder.DropForeignKey(
                name: "FK_Likes_UserAccounts_CreatedById",
                table: "Likes");

            migrationBuilder.RenameColumn(
                name: "CreatedById",
                table: "Likes",
                newName: "MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_Likes_PostId_CreatedById",
                table: "Likes",
                newName: "IX_Likes_PostId_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_Likes_CreatedById",
                table: "Likes",
                newName: "IX_Likes_MemberId");

            migrationBuilder.RenameColumn(
                name: "CreatedById",
                table: "Comments",
                newName: "MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_Comments_PostId_CreatedById_CreatedAt",
                table: "Comments",
                newName: "IX_Comments_PostId_MemberId_CreatedAt");

            migrationBuilder.RenameIndex(
                name: "IX_Comments_CreatedById",
                table: "Comments",
                newName: "IX_Comments_MemberId");

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

            migrationBuilder.AddForeignKey(
                name: "FK_Comments_Members_MemberId",
                table: "Comments",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Likes_Members_MemberId",
                table: "Likes",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "Id");
        }
    }
}
