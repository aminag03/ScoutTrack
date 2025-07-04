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
            var cityNames = new[]
            {
                "Banovići","Banja Luka","Bihać","Bijeljina","Bileća","Bosanski Brod","Bosanska Dubica","Bosanska Gradiška","Bosansko Grahovo",
                "Bosanska Krupa","Bosanski Novi","Bosanski Petrovac","Bosanski Šamac","Bratunac","Brčko","Breza","Bugojno","Busovača","Bužim",
                "Cazin","Čajniče","Čapljina","Čelić","Čelinac","Čitluk","Derventa","Doboj","Donji Vakuf","Drvar","Foča","Fojnica","Gacko","Glamoč",
                "Goražde","Gornji Vakuf","Gračanica","Gradačac","Grude","Hadžići","Han-Pijesak","Hlivno","Ilijaš","Jablanica","Jajce","Kakanj",
                "Kalesija","Kalinovik","Kiseljak","Kladanj","Ključ","Konjic","Kotor-Varoš","Kreševo","Kupres","Laktaši","Lopare","Lukavac","Ljubinje",
                "Ljubuški","Maglaj","Modriča","Mostar","Mrkonjić-Grad","Neum","Nevesinje","Novi Travnik","Odžak","Olovo","Orašje","Pale","Posušje",
                "Prijedor","Prnjavor","Prozor","Rogatica","Rudo","Sanski Most","Sarajevo","Skender-Vakuf","Sokolac","Srbac","Srebrenica",
                "Srebrenik","Stolac","Šekovići","Šipovo","Široki Brijeg","Teslić","Tešanj","Tomislav-Grad","Travnik","Trebinje","Trnovo","Tuzla",
                "Ugljevik","Vareš","Velika Kladuša","Visoko","Višegrad","Vitez","Vlasenica","Zavidovići","Zenica","Zvornik","Žepa","Žepče","Živinice"
            };

            var cities = new List<City>();
            int cityIdCounter = 1;
            foreach (var name in cityNames)
            {
                cities.Add(new City
                {
                    Id = cityIdCounter++,
                    Name = name
                });
            }
            modelBuilder.Entity<City>().HasData(cities);

            // Seed Admin
            var admin = new Admin
            {
                Id = 1,
                Username = "admin",
                Email = "admin@scouttrack.ba",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                Role = Role.Admin,
                CreatedAt = DateTime.UtcNow
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
                    CityId = 2, // Banja Luka
                    Name = "Troop Banja Luka"
                },
                new Troop
                {
                    Id = 3,
                    Username = "troopsarajevo",
                    Email = "troopsarajevo@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Troop,
                    CityId = 76, // Sarajevo
                    Name = "Troop Sarajevo"
                },
                new Troop
                {
                    Id = 4,
                    Username = "troopmostar",
                    Email = "troopmostar@scouttrack.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Pass123!"),
                    Role = Role.Troop,
                    CityId = 63, // Mostar
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
                    CityId = 76,
                    TroopId = 3
                }
            };
            modelBuilder.Entity<Member>().HasData(members);
        }
    }
}
