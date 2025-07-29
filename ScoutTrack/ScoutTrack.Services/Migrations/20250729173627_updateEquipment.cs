using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ScoutTrack.Services.Migrations
{
    /// <inheritdoc />
    public partial class updateEquipment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CreatedByTroopId",
                table: "Equipments",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsGlobal",
                table: "Equipments",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedByTroopId",
                table: "Equipments");

            migrationBuilder.DropColumn(
                name: "IsGlobal",
                table: "Equipments");
        }
    }
}
