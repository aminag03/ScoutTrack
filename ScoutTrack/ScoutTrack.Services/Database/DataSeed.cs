using Microsoft.EntityFrameworkCore;
using ScoutTrack.Common.Enums;
using ScoutTrack.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database
{
    public static class DataSeed
    {
        public static void Seed(ModelBuilder modelBuilder)
        {
            // Seed Cities
            var cities = new List<City>
            {
                new City { Id = 1, Name = "Sarajevo", Latitude = 43.8563, Longitude = 18.4131 },
                new City { Id = 2, Name = "Banja Luka", Latitude = 44.7722, Longitude = 17.191 },
                new City { Id = 3, Name = "Tuzla", Latitude = 44.54, Longitude = 18.679 },
                new City { Id = 4, Name = "Zenica", Latitude = 44.2036, Longitude = 17.9084 },
                new City { Id = 5, Name = "Mostar", Latitude = 43.3431, Longitude = 17.8078 },
                new City { Id = 6, Name = "Bihać", Latitude = 44.8167, Longitude = 15.8667 },
                new City { Id = 7, Name = "Bijeljina", Latitude = 44.7558, Longitude = 19.2144 },
                new City { Id = 8, Name = "Prijedor", Latitude = 44.9819, Longitude = 16.7133 },
                new City { Id = 9, Name = "Brčko", Latitude = 44.8756, Longitude = 18.802 },
                new City { Id = 10, Name = "Doboj", Latitude = 44.7372, Longitude = 18.0833 },
                new City { Id = 11, Name = "Cazin", Latitude = 44.9944, Longitude = 15.8225 },
                new City { Id = 12, Name = "Trebinje", Latitude = 42.7114, Longitude = 18.3444 },
                new City { Id = 13, Name = "Zvornik", Latitude = 44.3692, Longitude = 19.1064 },
                new City { Id = 14, Name = "Velika Kladuša", Latitude = 45.2122, Longitude = 15.8275 },
                new City { Id = 15, Name = "Gradačac", Latitude = 44.885, Longitude = 18.4533 },
                new City { Id = 16, Name = "Gračanica", Latitude = 44.4178, Longitude = 18.6717 },
                new City { Id = 17, Name = "Travnik", Latitude = 44.2294, Longitude = 17.6603 },
                new City { Id = 18, Name = "Sanski Most", Latitude = 44.7672, Longitude = 16.6867 },
                new City { Id = 19, Name = "Bugojno", Latitude = 44.0325, Longitude = 17.4556 },
                new City { Id = 20, Name = "Visoko", Latitude = 43.9839, Longitude = 18.1853 },
                new City { Id = 21, Name = "Kakanj", Latitude = 44.1475, Longitude = 18.1772 },
                new City { Id = 22, Name = "Lukavac", Latitude = 44.5439, Longitude = 18.6486 },
                new City { Id = 23, Name = "Srebrenik", Latitude = 44.555, Longitude = 18.4872 },
                new City { Id = 24, Name = "Zavidovići", Latitude = 44.4442, Longitude = 18.2236 },
                new City { Id = 25, Name = "Goražde", Latitude = 43.6717, Longitude = 18.9472 },
                new City { Id = 26, Name = "Konjic", Latitude = 43.6486, Longitude = 17.8619 },
                new City { Id = 27, Name = "Široki Brijeg", Latitude = 43.3531, Longitude = 17.4317 },
                new City { Id = 28, Name = "Čapljina", Latitude = 43.1094, Longitude = 17.6953 },
                new City { Id = 29, Name = "Grude", Latitude = 43.4675, Longitude = 17.3753 },
                new City { Id = 30, Name = "Jajce", Latitude = 44.3428, Longitude = 17.2714 },
                new City { Id = 31, Name = "Mrkonjić-Grad", Latitude = 44.5781, Longitude = 17.1539 },
                new City { Id = 32, Name = "Modriča", Latitude = 44.9686, Longitude = 18.0511 },
                new City { Id = 33, Name = "Bosanska Krupa", Latitude = 44.8833, Longitude = 16.15 },
                new City { Id = 34, Name = "Kiseljak", Latitude = 44.2722, Longitude = 18.1053 },
                new City { Id = 35, Name = "Čitluk", Latitude = 43.2025, Longitude = 17.6847 },
                new City { Id = 36, Name = "Neum", Latitude = 42.9258, Longitude = 17.6078 },
                new City { Id = 37, Name = "Livno", Latitude = 43.8253, Longitude = 17.0156 },
                new City { Id = 38, Name = "Tomislav-Grad", Latitude = 43.65, Longitude = 17.2167 },
                new City { Id = 39, Name = "Novi Travnik", Latitude = 44.2275, Longitude = 17.6592 },
                new City { Id = 40, Name = "Foča", Latitude = 43.4925, Longitude = 18.8056 },
                new City { Id = 41, Name = "Bosanski Petrovac", Latitude = 44.5597, Longitude = 16.0497 },
                new City { Id = 42, Name = "Banovići", Latitude = 44.4056, Longitude = 18.5314 },
                new City { Id = 43, Name = "Olovo", Latitude = 44.4453, Longitude = 18.5856 },
                new City { Id = 44, Name = "Ilijaš", Latitude = 43.9575, Longitude = 18.345 },
                new City { Id = 45, Name = "Tešanj", Latitude = 44.6111, Longitude = 18.4178 },
                new City { Id = 46, Name = "Kalesija", Latitude = 44.5369, Longitude = 18.705 },
                new City { Id = 47, Name = "Prozor", Latitude = 43.835, Longitude = 17.5733 },
                new City { Id = 49, Name = "Bosanska Gradiška", Latitude = 45.1453, Longitude = 17.2592 },
                new City {Id = 50, Name = "Stolac", Latitude = 43.0597, Longitude = 17.9444 },
            };
            modelBuilder.Entity<City>().HasData(cities);


            // Seed Admin
            var admin = new Admin
            {
                Id = 1,
                Username = "admin",
                Email = "admin@scouttrack.ba",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                Role = Role.Admin,
                CreatedAt = DateTime.Now
            };
            modelBuilder.Entity<Admin>().HasData(admin);

            // Seed Troops
            var troops = new List<Troop>
            {
                new Troop
                {
                    Id = 2,
                    Username = "troopbl",
                    Email = "troopbl@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Troop,
                    CityId = 2,
                    Name = "Troop Banja Luka"
                },
                new Troop
                {
                    Id = 3,
                    Username = "troopsarajevo",
                    Email = "troopsarajevo@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Troop,
                    CityId = 1,
                    Name = "Troop Sarajevo"
                },
                new Troop
                {
                    Id = 4,
                    Username = "troopmostar",
                    Email = "troopmostar@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Troop,
                    CityId = 5,
                    Name = "Troop Mostar"
                }
            };
            modelBuilder.Entity<Troop>().HasData(troops);

            // Seed Badges
            var badges = new List<Badge>
            {
                new Badge { Id = 1, Name = "First Aid", Description = "Basic first aid skills" },
                new Badge { Id = 2, Name = "Fire Safety", Description = "Learn how to safely handle fire" },
                new Badge { Id = 3, Name = "Map Reading", Description = "Orientation and map skills" }
            };
            modelBuilder.Entity<Badge>().HasData(badges);

            // Seed Members
            var members = new List<Member>
            {
                new Member
                {
                    Id = 5,
                    Username = "scout1",
                    Email = "scout1@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Member,
                    FirstName = "John",
                    LastName = "Doe",
                    BirthDate = new DateTime(2005, 5, 10),
                    Gender = Gender.Male,
                    CityId = 2,
                    TroopId = 2
                },
                new Member
                {
                    Id = 6,
                    Username = "scout2",
                    Email = "scout2@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Member,
                    FirstName = "Jane",
                    LastName = "Doe",
                    BirthDate = new DateTime(2003, 7, 10),
                    Gender = Gender.Female,
                    CityId = 3,
                    TroopId = 3
                }
            };
            modelBuilder.Entity<Member>().HasData(members);
        }
    }
}
