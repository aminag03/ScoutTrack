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
                new City { Id = 11, Name = "Stolac", Latitude = 43.0597, Longitude = 17.9444 },
                new City { Id = 12, Name = "Trebinje", Latitude = 42.7114, Longitude = 18.3444 },
                new City { Id = 13, Name = "Zvornik", Latitude = 44.3692, Longitude = 19.1064 },
                new City { Id = 14, Name = "Velika Kladuša", Latitude = 45.2122, Longitude = 15.8275 },
                new City { Id = 15, Name = "Gradačac", Latitude = 44.885, Longitude = 18.4533 },
                new City { Id = 16, Name = "Gračanica", Latitude = 44.4178, Longitude = 18.6717 },
                new City { Id = 17, Name = "Travnik", Latitude = 44.2294, Longitude = 17.6603 },
                new City { Id = 18, Name = "Sanski Most", Latitude = 44.7672, Longitude = 16.6867 },
                new City { Id = 19, Name = "Bugojno", Latitude = 44.0325, Longitude = 17.4556 },
                new City { Id = 20, Name = "Čapljina", Latitude = 43.1193, Longitude = 17.7033 }
            };
            modelBuilder.Entity<City>().HasData(cities);

            // Seed Admin
            var admin = new Admin
            {
                Id = 1,
                Username = "admin",
                Email = "sifbih@scouttrack.ba",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                FullName = "Savez izviđača Federacije Bosne i Hercegovine",
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
                    Username = "troop",
                    Email = "odredizvidjacastolac@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Troop,
                    CityId = 11,
                    Name = "Bregava",
                    Latitude = 43.0821280888191,
                    Longitude = 17.9624215509164,
                    ContactPhone = "+38761123456",
                    ScoutMaster = "Izudin Čolić",
                    TroopLeader = "Eldar Ratkušić",
                    FoundingDate = new DateTime(2017, 8, 15),
                    LogoUrl = "images/troops/1f68d71a-e207-4126-8a47-84ea42e3c990.jpg"
                },
                new Troop
                {
                    Id = 3,
                    Username = "scouts.igman92",
                    Email = "igman92.scoutgroup@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Troop,
                    CityId = 1,
                    Name = "Igman92",
                    Latitude = 43.8563,
                    Longitude = 18.4131,
                    ContactPhone = "+38763234567",
                    ScoutMaster = "Senka Čimpo",
                    TroopLeader = "Emir Uzunović",
                    FoundingDate = new DateTime(2008, 6, 20)
                },
                new Troop
                {
                    Id = 4,
                    Username = "oistarigrad",
                    Email = "oistarigrad@bih.net.ba",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Troop,
                    CityId = 5,
                    Name = "Stari Grad",
                    Latitude = 43.3431,
                    Longitude = 17.8078,
                    ContactPhone = "+38763345678",
                    ScoutMaster = "Nermin Zagorčić",
                    TroopLeader = "Nedim Jugo",
                    FoundingDate = new DateTime(2012, 9, 10)
                },
                new Troop
                {
                    Id = 5,
                    Username = "scouts_of_visoko",
                    Email = "oivisoko@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Troop,
                    CityId = 3,
                    Name = "Visoko",
                    Latitude = 43.9837,
                    Longitude = 18.1854,
                    ContactPhone = "+38761456789",
                    ScoutMaster = "Muhamed Šehić",
                    TroopLeader = "Emir Burić",
                    FoundingDate = new DateTime(2015, 4, 12)
                },
                new Troop
                {
                    Id = 6,
                    Username = "oi.lisac",
                    Email = "oi-lisac@sigze.org",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Troop,
                    CityId = 4,
                    Name = "Lisac",
                    Latitude = 44.2036,
                    Longitude = 17.9084,
                    ContactPhone = "+38762567890",
                    ScoutMaster = "Zekerijah Avdić",
                    TroopLeader = "Omar Okan",
                    FoundingDate = new DateTime(2018, 7, 8)
                }
            };
            modelBuilder.Entity<Troop>().HasData(troops);

            // Seed Categories
            var categories = new List<Category>
            {
                new Category 
                { 
                    Id = 1, 
                    Name = "Poletarac", 
                    MinAge = 0, 
                    MaxAge = 10, 
                    Description = "Najmlađi izviđači do 10 godina",
                    CreatedAt = DateTime.Now
                },
                new Category 
                { 
                    Id = 2, 
                    Name = "Mlađi izviđač", 
                    MinAge = 11, 
                    MaxAge = 14, 
                    Description = "Mlađi izviđači od 11 do 14 godina",
                    CreatedAt = DateTime.Now
                },
                new Category 
                { 
                    Id = 3, 
                    Name = "Stariji izviđač", 
                    MinAge = 15, 
                    MaxAge = 19, 
                    Description = "Stariji izviđači od 15 do 19 godina",
                    CreatedAt = DateTime.Now
                },
                new Category 
                { 
                    Id = 4, 
                    Name = "Brđan", 
                    MinAge = 20, 
                    MaxAge = 100, 
                    Description = "Brđani od 20 godina i stariji",
                    CreatedAt = DateTime.Now
                }
            };
            modelBuilder.Entity<Category>().HasData(categories);

            // Seed Members
            var members = new List<Member>
            {
                new Member
                {
                    Id = 7,
                    Username = "member",
                    Email = "aminagutosic03@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Amina",
                    LastName = "Gutošić",
                    BirthDate = new DateTime(2003, 10, 7),
                    Gender = Gender.Female,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 4,
                    ContactPhone = "+38763629533",
                    ProfilePictureUrl = "/images/members/aminagutosic.jpg"
                },
                new Member
                {
                    Id = 8,
                    Username = "fatima",
                    Email = "fatimasidran@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Fatima",
                    LastName = "Sidran",
                    BirthDate = new DateTime(2006, 3, 7),
                    Gender = Gender.Female,
                    CityId = 1,
                    TroopId = 3,
                    CategoryId = 3,
                    ContactPhone = "+38762234567"
                },
                new Member
                {
                    Id = 9,
                    Username = "farisa",
                    Email = "farisavojnovic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Farisa",
                    LastName = "Vojnović",
                    BirthDate = new DateTime(2007, 3, 15),
                    Gender = Gender.Female,
                    CityId = 5,
                    TroopId = 4,
                    CategoryId = 2,
                    ContactPhone = "+38761345678"
                },
                new Member
                {
                    Id = 10,
                    Username = "almin",
                    Email = "alminpehilj@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Almin",
                    LastName = "Pehilj",
                    BirthDate = new DateTime(2004, 9, 22),
                    Gender = Gender.Male,
                    CityId = 3,
                    TroopId = 5,
                    CategoryId = 3,
                    ContactPhone = "+38763456789"
                },
                new Member
                {
                    Id = 11,
                    Username = "mujo",
                    Email = "mustafazilic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Mustafa",
                    LastName = "Zilić",
                    BirthDate = new DateTime(2008, 12, 5),
                    Gender = Gender.Male,
                    CityId = 4,
                    TroopId = 6,
                    CategoryId = 2,
                    ContactPhone = "+38762567890"
                },
                new Member
                {
                    Id = 12,
                    Username = "selena",
                    Email = "selenakarabatak@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Selena",
                    LastName = "Karabatak",
                    BirthDate = new DateTime(2006, 1, 18),
                    Gender = Gender.Female,
                    CityId = 2,
                    TroopId = 2,
                    CategoryId = 3,
                    ContactPhone = "+38761678901"
                },
                new Member
                {
                    Id = 13,
                    Username = "said",
                    Email = "saidsefo@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Said",
                    LastName = "Sefo",
                    BirthDate = new DateTime(2009, 6, 30),
                    Gender = Gender.Male,
                    CityId = 1,
                    TroopId = 3,
                    CategoryId = 2,
                    ContactPhone = "+38761789012"
                },
                new Member
                {
                    Id = 14,
                    Username = "lamija",
                    Email = "lamijazilic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Lamija",
                    LastName = "Zilić",
                    BirthDate = new DateTime(2002, 4, 14),
                    Gender = Gender.Female,
                    CityId = 5,
                    TroopId = 4,
                    CategoryId = 4,
                    ContactPhone = "+38762890123"
                },
                new Member
                {
                    Id = 15,
                    Username = "mahir",
                    Email = "mahirmedar@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Mahir",
                    LastName = "Medar",
                    BirthDate = new DateTime(2007, 8, 25),
                    Gender = Gender.Male,
                    CityId = 3,
                    TroopId = 5,
                    CategoryId = 2,
                    ContactPhone = "+38763901234"
                },
                new Member
                {
                    Id = 16,
                    Username = "ajlin",
                    Email = "ajlinhajdarovic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Ajlin",
                    LastName = "Hajdarović",
                    BirthDate = new DateTime(2005, 11, 8),
                    Gender = Gender.Female,
                    CityId = 4,
                    TroopId = 6,
                    CategoryId = 3,
                    ContactPhone = "+38762012345"
                },
                // Additional members for Troop 2 (Bregava from Stolac)
                new Member
                {
                    Id = 17,
                    Username = "emir",
                    Email = "emirbegic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Emir",
                    LastName = "Begić",
                    BirthDate = new DateTime(2004, 7, 12),
                    Gender = Gender.Male,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 3,
                    ContactPhone = "+38763123456"
                },
                new Member
                {
                    Id = 18,
                    Username = "lejla",
                    Email = "lejlaahmedovic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Lejla",
                    LastName = "Ahmedović",
                    BirthDate = new DateTime(2006, 3, 25),
                    Gender = Gender.Female,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 2,
                    ContactPhone = "+38761234567"
                },
                new Member
                {
                    Id = 19,
                    Username = "haris",
                    Email = "hariskaradzic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Haris",
                    LastName = "Karadžić",
                    BirthDate = new DateTime(2003, 9, 18),
                    Gender = Gender.Male,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 4,
                    ContactPhone = "+38762345678"
                },
                new Member
                {
                    Id = 20,
                    Username = "mina",
                    Email = "minasuljic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Mina",
                    LastName = "Suljić",
                    BirthDate = new DateTime(2007, 12, 5),
                    Gender = Gender.Female,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 2,
                    ContactPhone = "+38763456789"
                },
                new Member
                {
                    Id = 21,
                    Username = "adnan",
                    Email = "adnandelic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Adnan",
                    LastName = "Delić",
                    BirthDate = new DateTime(2005, 4, 22),
                    Gender = Gender.Male,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 3,
                    ContactPhone = "+38761567890"
                },
                new Member
                {
                    Id = 22,
                    Username = "ajla",
                    Email = "ajlajusic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Ajla",
                    LastName = "Jusić",
                    BirthDate = new DateTime(2006, 8, 14),
                    Gender = Gender.Female,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 2,
                    ContactPhone = "+38762678901"
                },
                new Member
                {
                    Id = 23,
                    Username = "kenan",
                    Email = "kenankukic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Kenan",
                    LastName = "Kukić",
                    BirthDate = new DateTime(2004, 11, 30),
                    Gender = Gender.Male,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 3,
                    ContactPhone = "+38763789012"
                },
                new Member
                {
                    Id = 24,
                    Username = "sara",
                    Email = "saramujicic@gmail.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"),
                    Role = Role.Member,
                    FirstName = "Sara",
                    LastName = "Mujićić",
                    BirthDate = new DateTime(2008, 1, 16),
                    Gender = Gender.Female,
                    CityId = 11,
                    TroopId = 2,
                    CategoryId = 1,
                    ContactPhone = "+38761890123"
                }
            };
            modelBuilder.Entity<Member>().HasData(members);

            // Seed Badges
            var badges = new List<Badge>
            {
                new Badge { Id = 1, Name = "Bolničar", Description = "Osnovne vještine prve pomoći", ImageUrl = "images/badges/1f68d72g-e207-4126-8a47-84ea32e3c890.png" },
                new Badge { Id = 2, Name = "Astronom", Description = "Orijentacija uz pomoć zvijezda" },
                new Badge { Id = 3, Name = "Topograf", Description = "Orijentacija i vještine rada sa kartom" },
                new Badge { Id = 4, Name = "Čvorolog", Description = "Učenje osnovnih izviđačkih čvorova" },
                new Badge { Id = 5, Name = "Konačar", Description = "Vještine kampovanja i preživljavanja" },
                new Badge { Id = 6, Name = "Poznavatelj orijentacije", Description = "Navigacija i orijentacija u prirodi" },
                new Badge { Id = 7, Name = "Novinar", Description = "Vještine komunikacije i timskog rada" },
                new Badge { Id = 8, Name = "Ekolog", Description = "Zaštita okoliša i održivost" }
            };
            modelBuilder.Entity<Badge>().HasData(badges);

            // Seed Activity Types
            var activityTypes = new List<ActivityType>
            {
                new ActivityType { Id = 1, Name = "Kampovanje", Description = "Aktivnosti kampovanja preko noći" },
                new ActivityType { Id = 2, Name = "Šetnja", Description = "Planinarenje i aktivnosti pješačenja" },
                new ActivityType { Id = 3, Name = "Sport", Description = "Sportske i fizičke aktivnosti" },
                new ActivityType { Id = 4, Name = "Edukacija", Description = "Edukativne radionice i obuke" },
                new ActivityType { Id = 5, Name = "Društvene aktivnosti", Description = "Društvene i zajedničke aktivnosti" },
                new ActivityType { Id = 6, Name = "Volontiranje", Description = "Volonterski rad i aktivnosti u zajednici" }
            };
            modelBuilder.Entity<ActivityType>().HasData(activityTypes);

            // Seed Equipment
            var equipment = new List<Equipment>
            {
                new Equipment { Id = 1, Name = "Šator", Description = "Standardni izviđački šator", IsGlobal = true },
                new Equipment { Id = 2, Name = "Spavaća vreća", Description = "Topla spavaća vreća", IsGlobal = true },
                new Equipment { Id = 3, Name = "Ruksak", Description = "Veliki ruksak za kampovanje", IsGlobal = true },
                new Equipment { Id = 4, Name = "Kompas", Description = "Navigacijski kompas", IsGlobal = true },
                new Equipment { Id = 5, Name = "Karta", Description = "Topografska karta", IsGlobal = true },
                new Equipment { Id = 6, Name = "Prva pomoć", Description = "Komplet za prvu pomoć", IsGlobal = true },
                new Equipment { Id = 7, Name = "Konopac", Description = "Izviđački konopac", IsGlobal = true },
                new Equipment { Id = 8, Name = "Nož", Description = "Izviđački nož", IsGlobal = true },
                new Equipment { Id = 9, Name = "Flaša za vodu", Description = "Metalna flaša za vodu", IsGlobal = true },
                new Equipment { Id = 10, Name = "Svjetiljka", Description = "Baterijska svjetiljka", IsGlobal = true }
            };
            modelBuilder.Entity<Equipment>().HasData(equipment);

            // Seed Activities
            var activities = new List<Activity>
            {
                new Activity
                {
                    Id = 1,
                    Title = "Jesenji kamp na Jahorini",
                    Description = "Dvodnevni kamp na Jahorini sa osnovama preživljavanja",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(7),
                    EndTime = DateTime.Now.AddDays(9),
                    Latitude = 43.7333,
                    Longitude = 18.5667,
                    LocationName = "Jahorina, Sarajevo",
                    Fee = 50.00m,
                    CreatedAt = DateTime.Now.AddDays(-45),
                    TroopId = 3,
                    ActivityTypeId = 1,
                    Summary = "Odličan kamp za početnike i iskusne izviđače",
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "/images/activities/camping.jpg"
                },
                new Activity
                {
                    Id = 2,
                    Title = "Šetnja kroz Sutjesku",
                    Description = "Jednodnevna šetnja kroz Nacionalni park Sutjeska",
                    isPrivate = true, // Troop-only activity
                    StartTime = DateTime.Now.AddDays(14),
                    EndTime = DateTime.Now.AddDays(14).AddHours(8),
                    Latitude = 43.3333,
                    Longitude = 18.6833,
                    LocationName = "Sutjeska, Foča",
                    Fee = 25.00m,
                    CreatedAt = DateTime.Now.AddDays(-38),
                    TroopId = 4,
                    ActivityTypeId = 2,
                    Summary = "Prekrasna priroda i odličan trening",
                    ActivityState = "RegistrationsClosedActivityState",
                    ImagePath = "images/activities/sutjeska_walk.jpg"
                },
                new Activity
                {
                    Id = 3,
                    Title = "Fudbalski turnir",
                    Description = "Godišnji fudbalski turnir između izviđačkih grupa",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-7), // Past activity
                    EndTime = DateTime.Now.AddDays(-7).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Sportski teren, Stolac",
                    Fee = 10.00m,
                    CreatedAt = DateTime.Now.AddDays(-75),
                    TroopId = 2,
                    ActivityTypeId = 3,
                    Summary = "Odličan turnir sa 8 timova! Pobjednik je bio tim 'Bregava' iz Stoca. Ukupno 24 igrača je sudjelovalo u 12 utakmica. Turnir je bio odlično organizovan s dobrim duhom sporta i izviđačkim vrijednostima.",
                    ActivityState = "FinishedActivityState",
                    ImagePath = "images/activities/football_tournament.jpg"
                },
                new Activity
                {
                    Id = 4,
                    Title = "Radionica prve pomoći",
                    Description = "Edukativna radionica o osnovama prve pomoći",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(10),
                    EndTime = DateTime.Now.AddDays(10).AddHours(4),
                    Latitude = 44.54,
                    Longitude = 18.679,
                    LocationName = "Dom kulture, Tuzla",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-28),
                    TroopId = 5,
                    ActivityTypeId = 4,
                    Summary = "Važne vještine za svakodnevni život",
                    ActivityState = "DraftActivityState"
                },
                new Activity
                {
                    Id = 5,
                    Title = "Čišćenje rijeke Bosne",
                    Description = "Volonterska akcija čišćenja rijeke Bosne",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(28),
                    EndTime = DateTime.Now.AddDays(28).AddHours(5),
                    Latitude = 44.2036,
                    Longitude = 17.9084,
                    LocationName = "Rijeka Bosna, Zenica",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-15),
                    TroopId = 6,
                    ActivityTypeId = 6,
                    Summary = "Doprinos zaštiti okoliša",
                    ActivityState = "CancelledActivityState",
                    ImagePath = "/images/activities/cleaning_river.jpg"
                }
            };
            modelBuilder.Entity<Activity>().HasData(activities);

            // Seed Activity Equipment
            var activityEquipment = new List<ActivityEquipment>
            {
                new ActivityEquipment { Id = 1, ActivityId = 1, EquipmentId = 1, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 2, ActivityId = 1, EquipmentId = 2, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 3, ActivityId = 1, EquipmentId = 3, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 4, ActivityId = 1, EquipmentId = 6, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 5, ActivityId = 2, EquipmentId = 4, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 6, ActivityId = 2, EquipmentId = 5, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 7, ActivityId = 2, EquipmentId = 9, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 8, ActivityId = 4, EquipmentId = 6, CreatedAt = DateTime.Now }
            };
            modelBuilder.Entity<ActivityEquipment>().HasData(activityEquipment);

            // Seed Activity Registrations
            var activityRegistrations = new List<ActivityRegistration>
            {
                // Activity 1 (Jesenji kamp na Jahorini) - 6 registrations
                new ActivityRegistration { Id = 1, ActivityId = 1, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 2, ActivityId = 1, MemberId = 8, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 3, ActivityId = 1, MemberId = 12, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 4, ActivityId = 1, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 5, ActivityId = 1, MemberId = 10, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 6, ActivityId = 1, MemberId = 11, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                // Activity 2 (Šetnja kroz Sutjesku) - 3 registrations (reduced for variety)
                new ActivityRegistration { Id = 7, ActivityId = 2, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 8, ActivityId = 2, MemberId = 10, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 9, ActivityId = 2, MemberId = 13, Status = RegistrationStatus.Rejected, RegisteredAt = DateTime.Now.AddDays(-1) },
                // Activity 3 (Fudbalski turnir) - 8 registrations
                new ActivityRegistration { Id = 12, ActivityId = 3, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 13, ActivityId = 3, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-5) },
                new ActivityRegistration { Id = 14, ActivityId = 3, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 15, ActivityId = 3, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 16, ActivityId = 3, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 17, ActivityId = 3, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 18, ActivityId = 3, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 19, ActivityId = 3, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-2) },
                // Activity 4 (Radionica prve pomoći) - 7 registrations (added variety)
                new ActivityRegistration { Id = 20, ActivityId = 4, MemberId = 14, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 21, ActivityId = 4, MemberId = 15, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 22, ActivityId = 4, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 23, ActivityId = 4, MemberId = 8, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 24, ActivityId = 4, MemberId = 11, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now },
                // Additional registrations for variety (moved from Activity 2)
                // Note: Removed duplicate registration for Member 14 on Activity 4
                // Note: Removed duplicate registration for Member 15 on Activity 4
                // Activity 5 (Čišćenje rijeke Bosne) - 6 registrations (added variety)
                new ActivityRegistration { Id = 25, ActivityId = 5, MemberId = 16, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 26, ActivityId = 5, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 27, ActivityId = 5, MemberId = 10, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 28, ActivityId = 5, MemberId = 13, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                // Additional registrations for variety (moved from Activity 2)
                new ActivityRegistration { Id = 123, ActivityId = 5, MemberId = 14, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 124, ActivityId = 5, MemberId = 15, Status = RegistrationStatus.Rejected, RegisteredAt = DateTime.Now.AddDays(-2) },
               
                new ActivityRegistration { Id = 129, ActivityId = 7, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 130, ActivityId = 7, MemberId = 10, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-3) }
            };
            modelBuilder.Entity<ActivityRegistration>().HasData(activityRegistrations);

            // Seed Member Badges
            var memberBadges = new List<MemberBadge>
            {
                new MemberBadge { Id = 1, MemberId = 7, BadgeId = 1, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-30), CreatedAt = DateTime.Now.AddDays(-60) },
                new MemberBadge { Id = 2, MemberId = 7, BadgeId = 3, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-20), CreatedAt = DateTime.Now.AddDays(-45) },
                new MemberBadge { Id = 3, MemberId = 8, BadgeId = 1, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-25), CreatedAt = DateTime.Now.AddDays(-80) },
                new MemberBadge { Id = 4, MemberId = 8, BadgeId = 2, Status = MemberBadgeStatus.InProgress, CreatedAt = DateTime.Now.AddDays(-10) },
                new MemberBadge { Id = 5, MemberId = 9, BadgeId = 4, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-15), CreatedAt = DateTime.Now.AddDays(-30) },
                new MemberBadge { Id = 6, MemberId = 10, BadgeId = 1, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-40), CreatedAt = DateTime.Now.AddDays(-70) },
                new MemberBadge { Id = 7, MemberId = 12, BadgeId = 3, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-10), CreatedAt = DateTime.Now.AddDays(-25) },
                new MemberBadge { Id = 8, MemberId = 14, BadgeId = 1, Status = MemberBadgeStatus.Completed, CompletedAt = DateTime.Now.AddDays(-5), CreatedAt = DateTime.Now.AddDays(-20) },
                new MemberBadge { Id = 9, MemberId = 7, BadgeId = 4, Status = MemberBadgeStatus.InProgress, CreatedAt = DateTime.Now.AddDays(-90) },
                new MemberBadge { Id = 10, MemberId = 7, BadgeId = 5, Status = MemberBadgeStatus.InProgress, CreatedAt = DateTime.Now.AddDays(-57) },
                new MemberBadge { Id = 11, MemberId = 7, BadgeId = 6, Status = MemberBadgeStatus.InProgress, CreatedAt = DateTime.Now.AddDays(-68) },
            };
            modelBuilder.Entity<MemberBadge>().HasData(memberBadges);

            // Seed Friendships
            var friendships = new List<Friendship>
            {
                // Core friendships around Member 7 (Amina)
                new Friendship { Id = 1, RequesterId = 7, ResponderId = 8, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-30), RespondedAt = DateTime.Now.AddDays(-29) },
                new Friendship { Id = 2, RequesterId = 7, ResponderId = 12, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-25), RespondedAt = DateTime.Now.AddDays(-24) },
                new Friendship { Id = 3, RequesterId = 7, ResponderId = 9, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-20), RespondedAt = DateTime.Now.AddDays(-19) },
                new Friendship { Id = 4, RequesterId = 7, ResponderId = 10, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-18), RespondedAt = DateTime.Now.AddDays(-17) },
                
                // Friendships around Member 8 (Fatima)
                new Friendship { Id = 6, RequesterId = 8, ResponderId = 10, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-20), RespondedAt = DateTime.Now.AddDays(-19) },
                new Friendship { Id = 7, RequesterId = 8, ResponderId = 13, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-16), RespondedAt = DateTime.Now.AddDays(-15) },
                new Friendship { Id = 8, RequesterId = 8, ResponderId = 14, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-12), RespondedAt = DateTime.Now.AddDays(-11) },
                
                // Friendships around Member 9 (Farisa)
                new Friendship { Id = 9, RequesterId = 9, ResponderId = 11, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-15), RespondedAt = DateTime.Now.AddDays(-14) },
                new Friendship { Id = 10, RequesterId = 9, ResponderId = 12, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-13), RespondedAt = DateTime.Now.AddDays(-12) },
                new Friendship { Id = 11, RequesterId = 9, ResponderId = 15, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-10), RespondedAt = DateTime.Now.AddDays(-9) },
                
                // Friendships around Member 10 (Almin)
                new Friendship { Id = 12, RequesterId = 10, ResponderId = 14, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-10), RespondedAt = DateTime.Now.AddDays(-9) },
                new Friendship { Id = 13, RequesterId = 10, ResponderId = 16, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-8), RespondedAt = DateTime.Now.AddDays(-7) },
                
                // Friendships around Member 11 (Mustafa)
                new Friendship { Id = 14, RequesterId = 11, ResponderId = 13, Status = FriendshipStatus.Pending, RequestedAt = DateTime.Now.AddDays(-5) },
                new Friendship { Id = 15, RequesterId = 11, ResponderId = 16, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-7), RespondedAt = DateTime.Now.AddDays(-6) },
                
                // Friendships around Member 12 (Selena)
                new Friendship { Id = 16, RequesterId = 12, ResponderId = 16, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-8), RespondedAt = DateTime.Now.AddDays(-7) },
                new Friendship { Id = 17, RequesterId = 12, ResponderId = 13, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-6), RespondedAt = DateTime.Now.AddDays(-5) },
                
                // Friendships around Member 13 (Said)
                new Friendship { Id = 18, RequesterId = 13, ResponderId = 15, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-4), RespondedAt = DateTime.Now.AddDays(-3) },
                
                // Friendships around Member 14 (Lamija)
                new Friendship { Id = 19, RequesterId = 14, ResponderId = 15, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-3), RespondedAt = DateTime.Now.AddDays(-2) },
                new Friendship { Id = 20, RequesterId = 14, ResponderId = 16, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-2), RespondedAt = DateTime.Now.AddDays(-1) },
                
                // Friendships around Member 15 (Mahir)
                new Friendship { Id = 21, RequesterId = 15, ResponderId = 16, Status = FriendshipStatus.Pending, RequestedAt = DateTime.Now.AddDays(-1) },
                
                // Cross-troop friendships (members from different troops)
                new Friendship { Id = 22, RequesterId = 7, ResponderId = 13, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-14), RespondedAt = DateTime.Now.AddDays(-13) },
                new Friendship { Id = 23, RequesterId = 8, ResponderId = 9, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-11), RespondedAt = DateTime.Now.AddDays(-10) },
                new Friendship { Id = 24, RequesterId = 10, ResponderId = 12, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-9), RespondedAt = DateTime.Now.AddDays(-8) },
                new Friendship { Id = 25, RequesterId = 11, ResponderId = 14, Status = FriendshipStatus.Accepted, RequestedAt = DateTime.Now.AddDays(-6), RespondedAt = DateTime.Now.AddDays(-5) },
                
                // Recent friendship requests
                new Friendship { Id = 26, RequesterId = 16, ResponderId = 7, Status = FriendshipStatus.Pending, RequestedAt = DateTime.Now.AddDays(-1) },
                new Friendship { Id = 27, RequesterId = 9, ResponderId = 13, Status = FriendshipStatus.Pending, RequestedAt = DateTime.Now.AddHours(-12) }
            };
            modelBuilder.Entity<Friendship>().HasData(friendships);

            // Seed Posts (only for FinishedActivityState activities)
            var posts = new List<Post>
            {
                // Posts for Activity 3 (Fudbalski turnir - FinishedActivityState)
                new Post
                {
                    Id = 1,
                    Content = "Fudbalski turnir je bio odličan! Naš tim je osvojio treće mjesto. Već se radujem sljedećoj godini!",
                    ActivityId = 3, // FinishedActivityState
                    CreatedById = 11,
                    CreatedAt = DateTime.Now.AddDays(-1)
                },
                new Post
                {
                    Id = 2,
                    Content = "Turnir je bio pun zabave! Vidjela sam odlične golove i dobru igru. Organizacija je bila na najvišem nivou!",
                    ActivityId = 3, // FinishedActivityState
                    CreatedById = 7,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(2)
                },
                new Post
                {
                    Id = 3,
                    Content = "Ekipa 'Bregava' je zasluženo pobijedila! Njihova igra je bila fenomenalna. Čestitam pobjednicima! 🏆",
                    ActivityId = 3, // FinishedActivityState
                    CreatedById = 12,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(4)
                },
                // Posts for Activity 12 (Mostarska šetnja - FinishedActivityState)
                new Post
                {
                    Id = 4,
                    Content = "Mostarska šetnja je bila fascinantna! Posjetili smo Stari Most i naučili puno o historiji grada. Preporučujem svima!",
                    ActivityId = 12, // FinishedActivityState
                    CreatedById = 9,
                    CreatedAt = DateTime.Now.AddDays(-1)
                },
                new Post
                {
                    Id = 5,
                    Content = "Stari Most je stvarno impresivan! Vodič nam je objasnio kako je građen i zašto je tako važan za Mostar. 🌉",
                    ActivityId = 12, // FinishedActivityState
                    CreatedById = 8,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(1)
                },
                new Post
                {
                    Id = 6,
                    Content = "Koski Mehmed-pašina džamija je prekrasna! Arhitektura je nevjerovatna. 🕌",
                    ActivityId = 12, // FinishedActivityState
                    CreatedById = 10,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(3)
                },
                // Posts for Activity 19 (Turnir u košarci - FinishedActivityState)
                new Post
                {
                    Id = 7,
                    Content = "Turnir u košarci je bio fantastičan! Tim 'Bregava Eagles' je zasluženo pobijedio. Odlična organizacija i takmičarski duh! 🏀",
                    ActivityId = 19, // FinishedActivityState
                    CreatedById = 17,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(1)
                },
                new Post
                {
                    Id = 8,
                    Content = "Košarka je stvarno zabavna! Naučio sam puno o timskom radu i strategiji. Hvala organizatorima na odličnom turniru! 🏆",
                    ActivityId = 19, // FinishedActivityState
                    CreatedById = 19,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(2)
                },
                new Post
                {
                    Id = 9,
                    Content = "Odličan turnir! Vidio sam mnoge dobre igre i naučio o važnosti timskog rada. Već se radujem sljedećem turniru! ⚽",
                    ActivityId = 19, // FinishedActivityState
                    CreatedById = 21,
                    CreatedAt = DateTime.Now.AddDays(-1).AddHours(3)
                }
            };
            modelBuilder.Entity<Post>().HasData(posts);

            // Seed Comments (only for posts from finished activities)
            var comments = new List<Comment>
            {
                // Comments for Activity 3 posts
                new Comment { Id = 1, PostId = 1, CreatedById = 8, Content = "Slažem se! Turnir je bio odličan!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Comment { Id = 2, PostId = 1, CreatedById = 12, Content = "I ja sam se super zabavila na turniru!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Comment { Id = 3, PostId = 2, CreatedById = 11, Content = "Hvala! Bilo je stvarno zabavno! ⚽", CreatedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Comment { Id = 4, PostId = 2, CreatedById = 13, Content = "Organizacija je bila savršena!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(4) },
                new Comment { Id = 5, PostId = 3, CreatedById = 7, Content = "Eagles su stvarno zaslužili pobjedu! 🏆", CreatedAt = DateTime.Now.AddDays(-1).AddHours(5) },
                new Comment { Id = 6, PostId = 3, CreatedById = 8, Content = "Slažem se, igrali su fenomenalno!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(6) },
                // Comments for Activity 12 posts
                new Comment { Id = 7, PostId = 4, CreatedById = 10, Content = "Mostar je stvarno prekrasan grad!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(1) },
                new Comment { Id = 8, PostId = 4, CreatedById = 13, Content = "Stari Most je fascinantan!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Comment { Id = 9, PostId = 5, CreatedById = 9, Content = "Vodič je bio odličan! 📚", CreatedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Comment { Id = 10, PostId = 5, CreatedById = 11, Content = "Stari Most je arhitektonsko čudo!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Comment { Id = 11, PostId = 6, CreatedById = 8, Content = "Džamija je stvarno prekrasna! 🕌", CreatedAt = DateTime.Now.AddDays(-1).AddHours(4) },
                new Comment { Id = 12, PostId = 6, CreatedById = 12, Content = "Naučili smo puno o historiji!", CreatedAt = DateTime.Now.AddDays(-1).AddHours(5) }
            };
            modelBuilder.Entity<Comment>().HasData(comments);

            // Seed Badge Requirements
            var badgeRequirements = new List<BadgeRequirement>
            {
                new BadgeRequirement { Id = 1, BadgeId = 1, Description = "Demonstrirati osnovne tehnike prve pomoći", CreatedAt = DateTime.Now.AddDays(-60) },
                new BadgeRequirement { Id = 2, BadgeId = 1, Description = "Znati kako pozvati hitnu pomoć", CreatedAt = DateTime.Now.AddDays(-60) },
                new BadgeRequirement { Id = 3, BadgeId = 1, Description = "Praktično pokazati bandiranje rane", CreatedAt = DateTime.Now.AddDays(-60) },
                new BadgeRequirement { Id = 4, BadgeId = 2, Description = "Sigurno paliti i gasiti vatru", CreatedAt = DateTime.Now.AddDays(-50) },
                new BadgeRequirement { Id = 5, BadgeId = 2, Description = "Znati pravila sigurnosti oko vatre", CreatedAt = DateTime.Now.AddDays(-50) },
                new BadgeRequirement { Id = 6, BadgeId = 3, Description = "Čitati topografsku kartu", CreatedAt = DateTime.Now.AddDays(-45) },
                new BadgeRequirement { Id = 7, BadgeId = 3, Description = "Koristiti kompas za navigaciju", CreatedAt = DateTime.Now.AddDays(-45) },
                new BadgeRequirement { Id = 8, BadgeId = 4, Description = "Znati osnovne izviđačke čvorove", CreatedAt = DateTime.Now.AddDays(-40) },
                new BadgeRequirement { Id = 9, BadgeId = 4, Description = "Demonstrirati 5 različitih čvorova", CreatedAt = DateTime.Now.AddDays(-40) },
                new BadgeRequirement { Id = 10, BadgeId = 5, Description = "Postaviti šator samostalno", CreatedAt = DateTime.Now.AddDays(-35) },
                new BadgeRequirement { Id = 11, BadgeId = 5, Description = "Pripremiti sigurnu vatru", CreatedAt = DateTime.Now.AddDays(-35) },
                new BadgeRequirement { Id = 12, BadgeId = 6, Description = "Orijentirati se po suncu i zvijezdama", CreatedAt = DateTime.Now.AddDays(-30) },
                new BadgeRequirement { Id = 13, BadgeId = 6, Description = "Pronaći put bez karte", CreatedAt = DateTime.Now.AddDays(-30) },
                new BadgeRequirement { Id = 14, BadgeId = 7, Description = "Voditi grupu u aktivnosti", CreatedAt = DateTime.Now.AddDays(-25) },
                new BadgeRequirement { Id = 15, BadgeId = 7, Description = "Komunicirati s drugim članovima", CreatedAt = DateTime.Now.AddDays(-25) },
                new BadgeRequirement { Id = 16, BadgeId = 8, Description = "Sudjelovati u ekološkoj aktivnosti", CreatedAt = DateTime.Now.AddDays(-20) },
                new BadgeRequirement { Id = 17, BadgeId = 8, Description = "Edukovati se o zaštiti okoliša", CreatedAt = DateTime.Now.AddDays(-20) },
                new BadgeRequirement { Id = 18, BadgeId = 6, Description = "Poznavati osnove svemira", CreatedAt = DateTime.Now.AddDays(-30) }
            };
            modelBuilder.Entity<BadgeRequirement>().HasData(badgeRequirements);

            // Seed Member Badge Progress - Correct progress records for all member badges based on their badge requirements
            var memberBadgeProgresses = new List<MemberBadgeProgress>
            {
                // MemberBadge 1: Member 7, Badge 1 (Bolničar) - Requirements 1, 2, 3
                new MemberBadgeProgress { Id = 1, MemberBadgeId = 1, RequirementId = 1, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-35) },
                new MemberBadgeProgress { Id = 2, MemberBadgeId = 1, RequirementId = 2, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-32) },
                new MemberBadgeProgress { Id = 3, MemberBadgeId = 1, RequirementId = 3, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-30) },
                
                // MemberBadge 2: Member 7, Badge 3 (Topograf) - Requirements 6, 7
                new MemberBadgeProgress { Id = 4, MemberBadgeId = 2, RequirementId = 6, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-25) },
                new MemberBadgeProgress { Id = 5, MemberBadgeId = 2, RequirementId = 7, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-20) },
                
                // MemberBadge 3: Member 8, Badge 1 (Bolničar) - Requirements 1, 2, 3
                new MemberBadgeProgress { Id = 6, MemberBadgeId = 3, RequirementId = 1, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-40) },
                new MemberBadgeProgress { Id = 7, MemberBadgeId = 3, RequirementId = 2, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-38) },
                new MemberBadgeProgress { Id = 8, MemberBadgeId = 3, RequirementId = 3, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-35) },
                
                // MemberBadge 4: Member 8, Badge 2 (Astronom) - Requirements 4, 5
                new MemberBadgeProgress { Id = 9, MemberBadgeId = 4, RequirementId = 4, IsCompleted = false },
                new MemberBadgeProgress { Id = 10, MemberBadgeId = 4, RequirementId = 5, IsCompleted = false },
                
                // MemberBadge 5: Member 9, Badge 4 (Čvorolog) - Requirements 8, 9
                new MemberBadgeProgress { Id = 11, MemberBadgeId = 5, RequirementId = 8, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-8) },
                new MemberBadgeProgress { Id = 12, MemberBadgeId = 5, RequirementId = 9, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-6) },
                
                // MemberBadge 6: Member 10, Badge 1 (Bolničar) - Requirements 1, 2, 3
                new MemberBadgeProgress { Id = 13, MemberBadgeId = 6, RequirementId = 1, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-45) },
                new MemberBadgeProgress { Id = 14, MemberBadgeId = 6, RequirementId = 2, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-42) },
                new MemberBadgeProgress { Id = 15, MemberBadgeId = 6, RequirementId = 3, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-40) },
                
                // MemberBadge 7: Member 12, Badge 3 (Topograf) - Requirements 6, 7
                new MemberBadgeProgress { Id = 16, MemberBadgeId = 7, RequirementId = 6, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-15) },
                new MemberBadgeProgress { Id = 17, MemberBadgeId = 7, RequirementId = 7, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-12) },
                
                // MemberBadge 8: Member 14, Badge 1 (Bolničar) - Requirements 1, 2, 3
                new MemberBadgeProgress { Id = 18, MemberBadgeId = 8, RequirementId = 1, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-10) },
                new MemberBadgeProgress { Id = 19, MemberBadgeId = 8, RequirementId = 2, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-8) },
                new MemberBadgeProgress { Id = 20, MemberBadgeId = 8, RequirementId = 3, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-6) }
            };
            modelBuilder.Entity<MemberBadgeProgress>().HasData(memberBadgeProgresses);

            // Seed Member Badge Progress for new member badges (IDs 9, 10, 11)
            var newMemberBadgeProgresses = new List<MemberBadgeProgress>
            {
                // MemberBadge 9: Member 7, Badge 4 (Čvorolog) - Requirements 8, 9
                new MemberBadgeProgress { Id = 21, MemberBadgeId = 9, RequirementId = 8, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-30) },
                new MemberBadgeProgress { Id = 22, MemberBadgeId = 9, RequirementId = 9, IsCompleted = false },

                // MemberBadge 10: Member 7, Badge 5 (Konačar) - Requirements 10, 11
                new MemberBadgeProgress { Id = 23, MemberBadgeId = 10, RequirementId = 10, IsCompleted = false },
                new MemberBadgeProgress { Id = 24, MemberBadgeId = 10, RequirementId = 11, IsCompleted = false },

                // MemberBadge 11: Member 7, Badge 6 (Poznavatelj orijentacije) - Requirements 12, 13, 18
                new MemberBadgeProgress { Id = 25, MemberBadgeId = 11, RequirementId = 12, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-50) },
                new MemberBadgeProgress { Id = 26, MemberBadgeId = 11, RequirementId = 13, IsCompleted = true, CompletedAt = DateTime.Now.AddDays(-45) },
                new MemberBadgeProgress { Id = 27, MemberBadgeId = 11, RequirementId = 18, IsCompleted = false },
            };
            modelBuilder.Entity<MemberBadgeProgress>().HasData(newMemberBadgeProgresses);

            // Seed More Activities
            var moreActivities = new List<Activity>
            {
                new Activity
                {
                    Id = 6,
                    Title = "Zimski kamp na Rujištu",
                    Description = "Trodnevni zimski kamp u okolini Mostara sa fokusom na preživljavanje u zimskim uvjetima",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(35),
                    EndTime = DateTime.Now.AddDays(38),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Rujište, Mostar",
                    Fee = 75.00m,
                    CreatedAt = DateTime.Now.AddDays(-65),
                    TroopId = 2,
                    ActivityTypeId = 1,
                    Summary = "Izazovni zimski kamp za iskusne izviđače",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 7,
                    Title = "Radionica čvorova",
                    Description = "Edukativna radionica o osnovnim izviđačkim čvorovima i sigurnom radu s konopcem",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(12),
                    EndTime = DateTime.Now.AddDays(12).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Dom kulture, Stolac",
                    Fee = 15.00m,
                    CreatedAt = DateTime.Now.AddDays(-52),
                    TroopId = 2,
                    ActivityTypeId = 4,
                    Summary = "Osnovne vještine za sve izviđače",
                    ActivityState = "RegistrationsClosedActivityState"
                },
                new Activity
                {
                    Id = 8,
                    Title = "Šetnja uz Bregavu",
                    Description = "Jednodnevna šetnja uz rijeku Bregavu s edukacijom o lokalnoj flori i fauni",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(18),
                    EndTime = DateTime.Now.AddDays(18).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Rijeka Bregava, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-42),
                    TroopId = 2,
                    ActivityTypeId = 2,
                    Summary = "Prirodna edukacija i rekreacija uz Bregavu",
                    ActivityState = "DraftActivityState"
                },
                new Activity
                {
                    Id = 9,
                    Title = "Turnir u stolnom tenisu",
                    Description = "Godišnji turnir u stolnom tenisu između članova odreda",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(25),
                    EndTime = DateTime.Now.AddDays(25).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Sportski centar, Stolac",
                    Fee = 20.00m,
                    CreatedAt = DateTime.Now.AddDays(-35),
                    TroopId = 2,
                    ActivityTypeId = 3,
                    Summary = "Zabavni turnir za sve uzraste",
                    ActivityState = "RegistrationsClosedActivityState"
                },
                new Activity
                {
                    Id = 10,
                    Title = "Čišćenje okoline Bregave",
                    Description = "Volonterska akcija čišćenja okoline rijeke Bregave",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(30),
                    EndTime = DateTime.Now.AddDays(30).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Okolina Bregave, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-22),
                    TroopId = 2,
                    ActivityTypeId = 6,
                    Summary = "Doprinos zaštiti lokalnog okoliša",
                    ActivityState = "CancelledActivityState"
                }
            };
            modelBuilder.Entity<Activity>().HasData(moreActivities);

            // Seed Additional Activities for Different Troops and States
            var additionalActivities = new List<Activity>
            {
                // Troop 3 (Sarajevo) - DraftActivityState
                new Activity
                {
                    Id = 11,
                    Title = "Orijentacija u prirodi",
                    Description = "Edukativna aktivnost o orijentaciji i navigaciji u prirodi",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(15),
                    EndTime = DateTime.Now.AddDays(15).AddHours(6),
                    Latitude = 43.8563,
                    Longitude = 18.4131,
                    LocationName = "Park Ilidža, Sarajevo",
                    Fee = 20.00m,
                    CreatedAt = DateTime.Now.AddDays(-3),
                    TroopId = 3,
                    ActivityTypeId = 4,
                    Summary = "Osnovne vještine orijentacije",
                    ActivityState = "DraftActivityState"
                },
                // Troop 4 (Mostar) - FinishedActivityState
                new Activity
                {
                    Id = 12,
                    Title = "Mostarska šetnja",
                    Description = "Historijska šetnja kroz stari Mostar",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-14), // Past activity
                    EndTime = DateTime.Now.AddDays(-14).AddHours(4),
                    Latitude = 43.3431,
                    Longitude = 17.8078,
                    LocationName = "Stari Most, Mostar",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-95),
                    TroopId = 4,
                    ActivityTypeId = 5,
                    Summary = "Fascinantna šetnja kroz historiju Mostara! Posjetili smo Stari Most, Koski Mehmed-pašinu džamiju i čaršiju. Vodič nam je objasnio bogatu historiju grada i njegovu važnost u Bosni i Hercegovini. Učestvovalo je 15 izviđača koji su naučili puno o lokalnoj kulturi i tradiciji.",
                    ActivityState = "FinishedActivityState"
                },
                // Troop 5 (Tuzla) - RegistrationsOpenActivityState
                new Activity
                {
                    Id = 13,
                    Title = "Radionica ekologije",
                    Description = "Edukativna radionica o zaštiti okoliša",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(20),
                    EndTime = DateTime.Now.AddDays(20).AddHours(5),
                    Latitude = 44.54,
                    Longitude = 18.679,
                    LocationName = "Ekološki centar, Tuzla",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-5),
                    TroopId = 5,
                    ActivityTypeId = 6,
                    Summary = "Važnost zaštite okoliša",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                // Troop 6 (Zenica) - CancelledActivityState
                new Activity
                {
                    Id = 14,
                    Title = "Planinska šetnja",
                    Description = "Šetnja po planinskim stazama oko Zenice",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(25),
                    EndTime = DateTime.Now.AddDays(25).AddHours(8),
                    Latitude = 44.2036,
                    Longitude = 17.9084,
                    LocationName = "Planina Vranica, Zenica",
                    Fee = 15.00m,
                    CreatedAt = DateTime.Now.AddDays(-7),
                    TroopId = 6,
                    ActivityTypeId = 2,
                    Summary = "Planinska avantura",
                    ActivityState = "CancelledActivityState"
                },
                // Troop 2 (Stolac) - RegistrationsClosedActivityState
                new Activity
                {
                    Id = 15,
                    Title = "Radionica preživljavanja",
                    Description = "Intenzivna radionica o tehnikama preživljavanja u prirodi",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(12),
                    EndTime = DateTime.Now.AddDays(12).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Šuma Radimlja, Stolac",
                    Fee = 40.00m,
                    CreatedAt = DateTime.Now.AddDays(-10),
                    TroopId = 2,
                    ActivityTypeId = 4,
                    Summary = "Napredne tehnike preživljavanja",
                    ActivityState = "RegistrationsClosedActivityState"
                },
                // Additional activities for Troop 2 (Bregava from Stolac)
                new Activity
                {
                    Id = 16,
                    Title = "Šetnja kroz stari Stolac",
                    Description = "Historijska šetnja kroz stari dio Stoca s posjetom stećcima",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(45),
                    EndTime = DateTime.Now.AddDays(45).AddHours(4),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Stari Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-15),
                    TroopId = 2,
                    ActivityTypeId = 5,
                    Summary = "Edukativna šetnja kroz historiju",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 17,
                    Title = "Radionica ekologije",
                    Description = "Edukativna radionica o zaštiti okoliša i recikliranju",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(20),
                    EndTime = DateTime.Now.AddDays(20).AddHours(5),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Eko centar, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-12),
                    TroopId = 2,
                    ActivityTypeId = 6,
                    Summary = "Važnost zaštite okoliša",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 18,
                    Title = "Kamp na Hrgudu",
                    Description = "Dvodnevni kamp na planini Hrgud sa osnovama preživljavanja",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(60),
                    EndTime = DateTime.Now.AddDays(62),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Planina Hrgud, Stolac",
                    Fee = 60.00m,
                    CreatedAt = DateTime.Now.AddDays(-20),
                    TroopId = 2,
                    ActivityTypeId = 1,
                    Summary = "Izazovni kamp za sve uzraste",
                    ActivityState = "DraftActivityState"
                },
                new Activity
                {
                    Id = 19,
                    Title = "Turnir u košarci",
                    Description = "Godišnji turnir u košarci između članova grupe",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-14),
                    EndTime = DateTime.Now.AddDays(-14).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Sportski centar, Stolac",
                    Fee = 15.00m,
                    CreatedAt = DateTime.Now.AddDays(-88),
                    TroopId = 2,
                    ActivityTypeId = 3,
                    Summary = "Odličan turnir sa 4 tima! Pobjednik je bio tim 'Bregava Eagles'. Ukupno 16 igrača je sudjelovalo u 6 utakmica. Turnir je bio odlično organiziran s dobrim duhom sporta.",
                    ActivityState = "FinishedActivityState"
                },
                // Additional finished activities from previous months
                new Activity
                {
                    Id = 30,
                    Title = "Ljetni kamp na Blidinju",
                    Description = "Trodnevni ljetni kamp na Blidinju sa osnovama preživljavanja",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-45),
                    EndTime = DateTime.Now.AddDays(-43),
                    Latitude = 43.6333,
                    Longitude = 17.4833,
                    LocationName = "Blidinje",
                    Fee = 60.00m,
                    CreatedAt = DateTime.Now.AddDays(-120),
                    TroopId = 2,
                    ActivityTypeId = 1,
                    Summary = "Fantastičan ljetni kamp! Učestvovalo je 20 izviđača koji su naučili osnove preživljavanja u prirodi. Kamp je bio odlično organiziran s puno zabavnih aktivnosti i edukativnih sadržaja.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 31,
                    Title = "Radionica ekologije u Prirodnom parku Hutovo Blato",
                    Description = "Edukativna radionica o zaštiti okoliša u Prirodnom parku Hutovo Blato",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-60),
                    EndTime = DateTime.Now.AddDays(-60).AddHours(6),
                    Latitude = 43.0833,
                    Longitude = 17.4167,
                    LocationName = "Hutovo Blato, Čapljina",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-135),
                    TroopId = 4,
                    ActivityTypeId = 6,
                    Summary = "Odlična radionica o zaštiti okoliša! Posjetili smo Prirodni park Hutovo Blato i naučili o važnosti zaštite močvarnih područja. Učestvovalo je 15 izviđača koji su aktivno sudjelovali u čišćenju okoliša.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 32,
                    Title = "Šetnja kroz Sarajevo",
                    Description = "Povijesna šetnja kroz stari dio Sarajeva s posjetom Baščaršiji",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-90),
                    EndTime = DateTime.Now.AddDays(-90).AddHours(5),
                    Latitude = 43.8563,
                    Longitude = 18.4131,
                    LocationName = "Baščaršija, Sarajevo",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-150),
                    TroopId = 3,
                    ActivityTypeId = 5,
                    Summary = "Fascinantna šetnja kroz povijest Sarajeva! Posjetili smo Baščaršiju, Gazi Husrev-begovu džamiju i Sebilj. Vodič nam je objasnio bogatu povijest grada i njegovu važnost u Bosni i Hercegovini. Učestvovalo je 18 izviđača.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 33,
                    Title = "Turnir u odbojci",
                    Description = "Godišnji turnir u odbojci između izviđačkih grupa",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-75),
                    EndTime = DateTime.Now.AddDays(-75).AddHours(8),
                    Latitude = 44.54,
                    Longitude = 18.679,
                    LocationName = "Sportski centar, Tuzla",
                    Fee = 20.00m,
                    CreatedAt = DateTime.Now.AddDays(-140),
                    TroopId = 5,
                    ActivityTypeId = 3,
                    Summary = "Odličan turnir u odbojci! Sudjelovalo je 6 timova sa ukupno 24 igrača. Pobjednik je bio tim 'Tuzla Eagles'. Turnir je bio odlično organiziran s dobrim duhom sporta i izviđačkim vrijednostima.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 34,
                    Title = "Kamp na planini Vlašić",
                    Description = "Dvodnevni kamp na planini Vlašić sa fokusom na orijentaciju i navigaciju",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-375),
                    EndTime = DateTime.Now.AddDays(-373),
                    Latitude = 44.2833,
                    Longitude = 17.6667,
                    LocationName = "Vlašić, Travnik",
                    Fee = 45.00m,
                    CreatedAt = DateTime.Now.AddDays(-160),
                    TroopId = 6,
                    ActivityTypeId = 1,
                    Summary = "Izazovni kamp na Vlašiću! Učestvovalo je 16 izviđača koji su naučili napredne tehnike orijentacije i navigacije. Kamp je bio odlično organiziran s puno praktičnih vježbi.",
                    ActivityState = "FinishedActivityState"
                },
                // Additional finished activities from last year
                new Activity
                {
                    Id = 35,
                    Title = "Proljetni kamp na Skakavcu",
                    Description = "Trodnevni proljetni kamp na planini Skakavac sa osnovama preživljavanja",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-180),
                    EndTime = DateTime.Now.AddDays(-178),
                    Latitude = 43.8563,
                    Longitude = 18.4131,
                    LocationName = "Skakavac, Sarajevo",
                    Fee = 55.00m,
                    CreatedAt = DateTime.Now.AddDays(-220),
                    TroopId = 3,
                    ActivityTypeId = 1,
                    Summary = "Odličan proljetni kamp! Učestvovalo je 18 izviđača koji su naučili osnove preživljavanja u prirodi tokom proljeća. Kamp je bio odlično organizovan s puno zabavnih aktivnosti i edukativnih sadržaja.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 36,
                    Title = "Međugradski turnir u odbojci",
                    Description = "Godišnji međugradski turnir u odbojci između izviđačkih grupa iz različitih gradova",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-200),
                    EndTime = DateTime.Now.AddDays(-200).AddHours(10),
                    Latitude = 44.54,
                    Longitude = 18.679,
                    LocationName = "Sportski centar, Tuzla",
                    Fee = 25.00m,
                    CreatedAt = DateTime.Now.AddDays(-260),
                    TroopId = 5,
                    ActivityTypeId = 3,
                    Summary = "Fantastičan međugradski turnir! Sudjelovalo je 8 timova iz 6 različitih gradova sa ukupno 48 igrača. Pobjednik je bio tim 'Tuzla Phoenix'. Turnir je bio odlično organiziran s dobrim duhom sporta.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 37,
                    Title = "Historijska šetnja kroz Banja Luku",
                    Description = "Povijesna šetnja kroz staru Banju Luku s posjetom Gradskoj tvrđavi",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-230),
                    EndTime = DateTime.Now.AddDays(-230).AddHours(6),
                    Latitude = 44.7784,
                    Longitude = 17.1939,
                    LocationName = "Gradska tvrđava, Banja Luka",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-280),
                    TroopId = 2,
                    ActivityTypeId = 5,
                    Summary = "Fascinantna šetnja kroz povijest Banje Luke! Posjetili smo Gradsku tvrđavu, Katedralu Krista Kralja i Kastel. Vodič nam je objasnio bogatu povijest grada. Učestvovalo je 16 izviđača.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 38,
                    Title = "Ekološka akcija 'Čistimo Bregavu'",
                    Description = "Velika ekološka akcija čišćenja okoline rijeke Bregave",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-250),
                    EndTime = DateTime.Now.AddDays(-250).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Rijeka Bregava, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-290),
                    TroopId = 2,
                    ActivityTypeId = 6,
                    Summary = "Odlična ekološka akcija! Sakupljeno je preko 200 kg smeća sa obala Bregave. Učestvovalo je 25 izviđača koji su doprinijeli zaštiti okoliša svoje zajednice.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 39,
                    Title = "Zimski kamp na Jahorini",
                    Description = "Trodnevni zimski kamp na Jahorini sa skijanjem i sankanjem",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(-300),
                    EndTime = DateTime.Now.AddDays(-298),
                    Latitude = 43.7333,
                    Longitude = 18.5667,
                    LocationName = "Jahorina, Sarajevo",
                    Fee = 80.00m,
                    CreatedAt = DateTime.Now.AddDays(-330),
                    TroopId = 3,
                    ActivityTypeId = 1,
                    Summary = "Fantastičan zimski kamp! Učestvovalo je 20 izviđača koji su naučili skijanje i rad na snijegu. Kamp je bio odlično organiziran s puno zimskih aktivnosti i snowboard radionice.",
                    ActivityState = "FinishedActivityState"
                },
                new Activity
                {
                    Id = 20,
                    Title = "Radionica prve pomoći",
                    Description = "Edukativna radionica o osnovama prve pomoći za mlađe članove",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(30),
                    EndTime = DateTime.Now.AddDays(30).AddHours(4),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Dom zdravlja, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-58),
                    TroopId = 2,
                    ActivityTypeId = 4,
                    Summary = "Važne vještine za svakodnevni život",
                    ActivityState = "RegistrationsClosedActivityState"
                },
                new Activity
                {
                    Id = 21,
                    Title = "Orijentacija u prirodi",
                    Description = "Edukativna aktivnost o orijentaciji i navigaciji u prirodi",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(25),
                    EndTime = DateTime.Now.AddDays(25).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Park, Stolac",
                    Fee = 20.00m,
                    CreatedAt = DateTime.Now.AddDays(-48),
                    TroopId = 2,
                    ActivityTypeId = 4,
                    Summary = "Osnovne vještine orijentacije",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 22,
                    Title = "Volontiranje u domovima",
                    Description = "Volonterska aktivnost u domovima za starije osobe",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(35),
                    EndTime = DateTime.Now.AddDays(35).AddHours(4),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Dom za starije osobe, Stolac",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-38),
                    TroopId = 2,
                    ActivityTypeId = 6,
                    Summary = "Doprinos lokalnoj zajednici",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 23,
                    Title = "Turnir u stolnom tenisu",
                    Description = "Godišnji turnir u stolnom tenisu između članova grupe",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(40),
                    EndTime = DateTime.Now.AddDays(40).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Sportski centar, Stolac",
                    Fee = 15.00m,
                    CreatedAt = DateTime.Now.AddDays(-32),
                    TroopId = 2,
                    ActivityTypeId = 3,
                    Summary = "Zabavni turnir za sve uzraste",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 24,
                    Title = "Edukativna šetnja kroz povijest",
                    Description = "Povijesna šetnja kroz stari dio Stoca s posjetom stećcima",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(50),
                    EndTime = DateTime.Now.AddDays(50).AddHours(5),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Stari Stolac",
                    Fee = 10.00m,
                    CreatedAt = DateTime.Now.AddDays(-68),
                    TroopId = 2,
                    ActivityTypeId = 5,
                    Summary = "Edukativna šetnja kroz povijest",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 25,
                    Title = "Radionica preživljavanja",
                    Description = "Intenzivna radionica o tehnikama preživljavanja u prirodi",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(28),
                    EndTime = DateTime.Now.AddDays(28).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Šivalovci",
                    Fee = 35.00m,
                    CreatedAt = DateTime.Now.AddDays(-3),
                    TroopId = 2,
                    ActivityTypeId = 4,
                    Summary = "Napredne tehnike preživljavanja",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 26,
                    Title = "Kampovanje na Igmanu",
                    Description = "Dvodnevni kamp na planini Igman sa osnovama preživljavanja",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(32),
                    EndTime = DateTime.Now.AddDays(34),
                    Latitude = 43.8563,
                    Longitude = 18.4131,
                    LocationName = "Igman",
                    Fee = 65.00m,
                    CreatedAt = DateTime.Now.AddDays(-7),
                    TroopId = 3,
                    ActivityTypeId = 1,
                    Summary = "Izazovni kamp za iskusne izviđače",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 27,
                    Title = "Radionica ekologije",
                    Description = "Edukativna radionica o zaštiti okoliša i recikliranju",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(38),
                    EndTime = DateTime.Now.AddDays(38).AddHours(5),
                    Latitude = 43.3431,
                    Longitude = 17.8078,
                    LocationName = "Eko centar, Mostar",
                    Fee = 0.00m,
                    CreatedAt = DateTime.Now.AddDays(-6),
                    TroopId = 4,
                    ActivityTypeId = 6,
                    Summary = "Važnost zaštite okoliša",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 28,
                    Title = "Šetnja kroz Tuzlu",
                    Description = "Povijesna šetnja kroz centar Tuzle s posjetom muzejima",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(42),
                    EndTime = DateTime.Now.AddDays(42).AddHours(6),
                    Latitude = 44.54,
                    Longitude = 18.679,
                    LocationName = "Centar Tuzle",
                    Fee = 15.00m,
                    CreatedAt = DateTime.Now.AddDays(-5),
                    TroopId = 5,
                    ActivityTypeId = 5,
                    Summary = "Edukativna šetnja kroz povijest",
                    ActivityState = "RegistrationsOpenActivityState"
                },
                new Activity
                {
                    Id = 29,
                    Title = "Turnir u košarci",
                    Description = "Godišnji turnir u košarci između članova grupe",
                    isPrivate = true,
                    StartTime = DateTime.Now.AddDays(45),
                    EndTime = DateTime.Now.AddDays(45).AddHours(8),
                    Latitude = 44.2036,
                    Longitude = 17.9084,
                    LocationName = "Sportski centar, Zenica",
                    Fee = 20.00m,
                    CreatedAt = DateTime.Now.AddDays(-4),
                    TroopId = 6,
                    ActivityTypeId = 3,
                    Summary = "Zabavni turnir za sve uzraste",
                    ActivityState = "RegistrationsOpenActivityState"
                }
            };
            modelBuilder.Entity<Activity>().HasData(additionalActivities);

            var moreActivityEquipment = new List<ActivityEquipment>
            {
                new ActivityEquipment { Id = 9, ActivityId = 6, EquipmentId = 1, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 10, ActivityId = 6, EquipmentId = 2, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 11, ActivityId = 6, EquipmentId = 3, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 12, ActivityId = 6, EquipmentId = 6, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 13, ActivityId = 6, EquipmentId = 10, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 14, ActivityId = 7, EquipmentId = 7, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 15, ActivityId = 8, EquipmentId = 4, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 16, ActivityId = 8, EquipmentId = 5, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 17, ActivityId = 8, EquipmentId = 9, CreatedAt = DateTime.Now },
                new ActivityEquipment { Id = 18, ActivityId = 10, EquipmentId = 6, CreatedAt = DateTime.Now }
            };
            modelBuilder.Entity<ActivityEquipment>().HasData(moreActivityEquipment);

            // Seed More Activity Registrations
            var moreActivityRegistrations = new List<ActivityRegistration>
            {
                // Activity 6 (Zimski kamp na Kozari) - 6 registrations
                new ActivityRegistration { Id = 29, ActivityId = 6, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 30, ActivityId = 6, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-7) },
                new ActivityRegistration { Id = 31, ActivityId = 6, MemberId = 8, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 32, ActivityId = 6, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-5) },
                new ActivityRegistration { Id = 33, ActivityId = 6, MemberId = 10, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 34, ActivityId = 6, MemberId = 11, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-3) },
                // Activity 7 (Radionica čvorova i konopca) - 5 registrations
                new ActivityRegistration { Id = 35, ActivityId = 7, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 36, ActivityId = 7, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-5) },
                new ActivityRegistration { Id = 37, ActivityId = 7, MemberId = 13, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 38, ActivityId = 7, MemberId = 14, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 39, ActivityId = 7, MemberId = 15, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-2) },
                // Activity 8 (Šetnja kroz Vrbas) - 4 registrations
                new ActivityRegistration { Id = 40, ActivityId = 8, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 41, ActivityId = 8, MemberId = 12, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 42, ActivityId = 8, MemberId = 8, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 43, ActivityId = 8, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                // Activity 9 (Turnir u stolnom tenisu) - 6 registrations
                new ActivityRegistration { Id = 44, ActivityId = 9, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 45, ActivityId = 9, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 46, ActivityId = 9, MemberId = 10, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 47, ActivityId = 9, MemberId = 11, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 48, ActivityId = 9, MemberId = 13, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 49, ActivityId = 9, MemberId = 16, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now },
                // Activity 10 (Čišćenje šume Kastel) - 5 registrations
                new ActivityRegistration { Id = 50, ActivityId = 10, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 51, ActivityId = 10, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 52, ActivityId = 10, MemberId = 8, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 53, ActivityId = 10, MemberId = 9, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 54, ActivityId = 10, MemberId = 14, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now }
            };
            modelBuilder.Entity<ActivityRegistration>().HasData(moreActivityRegistrations);

            // Seed Additional Activity Registrations for Troop 2 new members and activities
            var additionalActivityRegistrations = new List<ActivityRegistration>
            {
                // Registrations for Activity 16 (Šetnja kroz stari Stolac)
                new ActivityRegistration { Id = 55, ActivityId = 16, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-14) },
                new ActivityRegistration { Id = 56, ActivityId = 16, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-13) },
                new ActivityRegistration { Id = 57, ActivityId = 16, MemberId = 17, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-12) },
                new ActivityRegistration { Id = 58, ActivityId = 16, MemberId = 18, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-11) },
                new ActivityRegistration { Id = 59, ActivityId = 16, MemberId = 19, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-10) },
                new ActivityRegistration { Id = 60, ActivityId = 16, MemberId = 20, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-9) },
                
                // Registrations for Activity 17 (Radionica ekologije)
                new ActivityRegistration { Id = 61, ActivityId = 17, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-11) },
                new ActivityRegistration { Id = 62, ActivityId = 17, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-10) },
                new ActivityRegistration { Id = 63, ActivityId = 17, MemberId = 18, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-9) },
                new ActivityRegistration { Id = 64, ActivityId = 17, MemberId = 20, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 65, ActivityId = 17, MemberId = 22, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-7) },
                new ActivityRegistration { Id = 66, ActivityId = 17, MemberId = 24, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-6) },
                
                // Registrations for Activity 18 (Kamp na Badnju)
                new ActivityRegistration { Id = 67, ActivityId = 18, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-19) },
                new ActivityRegistration { Id = 68, ActivityId = 18, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-18) },
                new ActivityRegistration { Id = 69, ActivityId = 18, MemberId = 17, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-17) },
                new ActivityRegistration { Id = 70, ActivityId = 18, MemberId = 19, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-16) },
                new ActivityRegistration { Id = 71, ActivityId = 18, MemberId = 21, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-15) },
                new ActivityRegistration { Id = 72, ActivityId = 18, MemberId = 23, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-14) },
                
                // Completed registrations for Activity 19 (Turnir u košarci - FinishedActivityState)
                new ActivityRegistration { Id = 73, ActivityId = 19, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-20) },
                new ActivityRegistration { Id = 74, ActivityId = 19, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-19) },
                new ActivityRegistration { Id = 75, ActivityId = 19, MemberId = 17, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-18) },
                new ActivityRegistration { Id = 76, ActivityId = 19, MemberId = 19, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-17) },
                new ActivityRegistration { Id = 77, ActivityId = 19, MemberId = 21, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-16) },
                new ActivityRegistration { Id = 78, ActivityId = 19, MemberId = 23, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-15) },
                new ActivityRegistration { Id = 79, ActivityId = 19, MemberId = 18, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-14) },
                new ActivityRegistration { Id = 80, ActivityId = 19, MemberId = 20, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-13) },
                
                // Registrations for Activity 20 (Radionica prve pomoći)
                new ActivityRegistration { Id = 81, ActivityId = 20, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-9) },
                new ActivityRegistration { Id = 82, ActivityId = 20, MemberId = 12, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 83, ActivityId = 20, MemberId = 18, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-7) },
                new ActivityRegistration { Id = 84, ActivityId = 20, MemberId = 20, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 85, ActivityId = 20, MemberId = 22, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-5) },
                new ActivityRegistration { Id = 86, ActivityId = 20, MemberId = 24, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-4) },
                
                // Additional registrations for existing Troop 2 activities with new members
                // Activity 3 (Fudbalski turnir - FinishedActivityState)
                new ActivityRegistration { Id = 87, ActivityId = 3, MemberId = 17, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 88, ActivityId = 3, MemberId = 19, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-7) },
                new ActivityRegistration { Id = 89, ActivityId = 3, MemberId = 21, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 90, ActivityId = 3, MemberId = 23, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-5) },
                
                // Completed registrations for new finished activities from previous months
                // Activity 30 (Ljetni kamp na Blidinju - FinishedActivityState) - 1.5 months ago
                new ActivityRegistration { Id = 132, ActivityId = 30, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-50) },
                new ActivityRegistration { Id = 133, ActivityId = 30, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-49) },
                new ActivityRegistration { Id = 134, ActivityId = 30, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-48) },
                new ActivityRegistration { Id = 135, ActivityId = 30, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-47) },
                new ActivityRegistration { Id = 136, ActivityId = 30, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-46) },
                new ActivityRegistration { Id = 137, ActivityId = 30, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-45) },
                new ActivityRegistration { Id = 138, ActivityId = 30, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-44) },
                new ActivityRegistration { Id = 139, ActivityId = 30, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-43) },
                new ActivityRegistration { Id = 140, ActivityId = 30, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-42) },
                new ActivityRegistration { Id = 141, ActivityId = 30, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-41) },
                
                // Activity 31 (Radionica ekologije u Hutovo Blato - FinishedActivityState) - 2 months ago
                new ActivityRegistration { Id = 142, ActivityId = 31, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-65) },
                new ActivityRegistration { Id = 143, ActivityId = 31, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-64) },
                new ActivityRegistration { Id = 144, ActivityId = 31, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-63) },
                new ActivityRegistration { Id = 145, ActivityId = 31, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-62) },
                new ActivityRegistration { Id = 146, ActivityId = 31, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-61) },
                new ActivityRegistration { Id = 147, ActivityId = 31, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-60) },
                new ActivityRegistration { Id = 148, ActivityId = 31, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-59) },
                new ActivityRegistration { Id = 149, ActivityId = 31, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-58) },
                new ActivityRegistration { Id = 150, ActivityId = 31, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-57) },
                
                // Activity 32 (Šetnja kroz stari Sarajevo - FinishedActivityState) - 3 months ago
                new ActivityRegistration { Id = 151, ActivityId = 32, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-95) },
                new ActivityRegistration { Id = 152, ActivityId = 32, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-94) },
                new ActivityRegistration { Id = 153, ActivityId = 32, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-93) },
                new ActivityRegistration { Id = 154, ActivityId = 32, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-92) },
                new ActivityRegistration { Id = 155, ActivityId = 32, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-91) },
                new ActivityRegistration { Id = 156, ActivityId = 32, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-90) },
                new ActivityRegistration { Id = 157, ActivityId = 32, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-89) },
                new ActivityRegistration { Id = 158, ActivityId = 32, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-88) },
                new ActivityRegistration { Id = 159, ActivityId = 32, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-87) },
                new ActivityRegistration { Id = 160, ActivityId = 32, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-86) },
                
                // Activity 33 (Turnir u odbojci - FinishedActivityState) - 2.5 months ago
                new ActivityRegistration { Id = 161, ActivityId = 33, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-80) },
                new ActivityRegistration { Id = 162, ActivityId = 33, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-79) },
                new ActivityRegistration { Id = 163, ActivityId = 33, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-78) },
                new ActivityRegistration { Id = 164, ActivityId = 33, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-77) },
                new ActivityRegistration { Id = 165, ActivityId = 33, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-76) },
                new ActivityRegistration { Id = 166, ActivityId = 33, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-75) },
                new ActivityRegistration { Id = 167, ActivityId = 33, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-74) },
                new ActivityRegistration { Id = 168, ActivityId = 33, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-73) },
                new ActivityRegistration { Id = 169, ActivityId = 33, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-72) },
                new ActivityRegistration { Id = 170, ActivityId = 33, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-71) },
                
                // Activity 34 (Kamp na planini Vlašić - FinishedActivityState) - 3.5 months ago
                new ActivityRegistration { Id = 171, ActivityId = 34, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-110) },
                new ActivityRegistration { Id = 172, ActivityId = 34, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-109) },
                new ActivityRegistration { Id = 173, ActivityId = 34, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-108) },
                new ActivityRegistration { Id = 174, ActivityId = 34, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-107) },
                new ActivityRegistration { Id = 175, ActivityId = 34, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-106) },
                new ActivityRegistration { Id = 176, ActivityId = 34, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-105) },
                new ActivityRegistration { Id = 177, ActivityId = 34, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-104) },
                new ActivityRegistration { Id = 178, ActivityId = 34, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-103) },
                new ActivityRegistration { Id = 179, ActivityId = 34, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-102) },
                new ActivityRegistration { Id = 180, ActivityId = 34, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-101) },
                
                // Completed registrations for year-old finished activities
                // Activity 35 (Prolećni kamp na Skakavcu - FinishedActivityState) - 6 months ago
                new ActivityRegistration { Id = 181, ActivityId = 35, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-185) },
                new ActivityRegistration { Id = 182, ActivityId = 35, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-184) },
                new ActivityRegistration { Id = 183, ActivityId = 35, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-183) },
                new ActivityRegistration { Id = 184, ActivityId = 35, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-182) },
                new ActivityRegistration { Id = 185, ActivityId = 35, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-181) },
                new ActivityRegistration { Id = 186, ActivityId = 35, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-180) },
                new ActivityRegistration { Id = 187, ActivityId = 35, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-179) },
                new ActivityRegistration { Id = 188, ActivityId = 35, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-178) },
                new ActivityRegistration { Id = 189, ActivityId = 35, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-177) },
                new ActivityRegistration { Id = 190, ActivityId = 35, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-176) },
                
                // Activity 36 (Međugradski turnir u odbojci - FinishedActivityState) - 6.5 months ago
                new ActivityRegistration { Id = 191, ActivityId = 36, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-205) },
                new ActivityRegistration { Id = 192, ActivityId = 36, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-204) },
                new ActivityRegistration { Id = 193, ActivityId = 36, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-203) },
                new ActivityRegistration { Id = 194, ActivityId = 36, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-202) },
                new ActivityRegistration { Id = 195, ActivityId = 36, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-201) },
                new ActivityRegistration { Id = 196, ActivityId = 36, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-200) },
                new ActivityRegistration { Id = 197, ActivityId = 36, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-199) },
                new ActivityRegistration { Id = 198, ActivityId = 36, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-198) },
                new ActivityRegistration { Id = 199, ActivityId = 36, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-197) },
                new ActivityRegistration { Id = 200, ActivityId = 36, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-196) },
                
                // Activity 37 (Historijska šetnja kroz Banja Luku - FinishedActivityState) - 7.5 months ago
                new ActivityRegistration { Id = 201, ActivityId = 37, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-235) },
                new ActivityRegistration { Id = 202, ActivityId = 37, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-234) },
                new ActivityRegistration { Id = 203, ActivityId = 37, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-233) },
                new ActivityRegistration { Id = 204, ActivityId = 37, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-232) },
                new ActivityRegistration { Id = 205, ActivityId = 37, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-231) },
                new ActivityRegistration { Id = 206, ActivityId = 37, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-230) },
                new ActivityRegistration { Id = 207, ActivityId = 37, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-229) },
                new ActivityRegistration { Id = 208, ActivityId = 37, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-228) },
                new ActivityRegistration { Id = 209, ActivityId = 37, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-227) },
                new ActivityRegistration { Id = 210, ActivityId = 37, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-226) },
                
                // Activity 38 (Ekološka akcija 'Čisti Bregava' - FinishedActivityState) - 8 months ago
                new ActivityRegistration { Id = 211, ActivityId = 38, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-255) },
                new ActivityRegistration { Id = 212, ActivityId = 38, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-254) },
                new ActivityRegistration { Id = 213, ActivityId = 38, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-253) },
                new ActivityRegistration { Id = 214, ActivityId = 38, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-252) },
                new ActivityRegistration { Id = 215, ActivityId = 38, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-251) },
                new ActivityRegistration { Id = 216, ActivityId = 38, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-250) },
                new ActivityRegistration { Id = 217, ActivityId = 38, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-249) },
                new ActivityRegistration { Id = 218, ActivityId = 38, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-248) },
                new ActivityRegistration { Id = 219, ActivityId = 38, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-247) },
                new ActivityRegistration { Id = 220, ActivityId = 38, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-246) },
                
                // Activity 39 (Zimski kamp na Jahorini - FinishedActivityState) - 10 months ago
                new ActivityRegistration { Id = 221, ActivityId = 39, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-305) },
                new ActivityRegistration { Id = 222, ActivityId = 39, MemberId = 8, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-304) },
                new ActivityRegistration { Id = 223, ActivityId = 39, MemberId = 9, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-303) },
                new ActivityRegistration { Id = 224, ActivityId = 39, MemberId = 10, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-302) },
                new ActivityRegistration { Id = 225, ActivityId = 39, MemberId = 11, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-301) },
                new ActivityRegistration { Id = 226, ActivityId = 39, MemberId = 12, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-300) },
                new ActivityRegistration { Id = 227, ActivityId = 39, MemberId = 13, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-299) },
                new ActivityRegistration { Id = 228, ActivityId = 39, MemberId = 14, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-298) },
                new ActivityRegistration { Id = 229, ActivityId = 39, MemberId = 15, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-297) },
                new ActivityRegistration { Id = 230, ActivityId = 39, MemberId = 16, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-296) },
                
                // Activity 6 (Zimski kamp na Radimlji)
                new ActivityRegistration { Id = 91, ActivityId = 6, MemberId = 17, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 92, ActivityId = 6, MemberId = 19, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-7) },
                new ActivityRegistration { Id = 93, ActivityId = 6, MemberId = 21, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 94, ActivityId = 6, MemberId = 23, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-5) },
                
                // Activity 7 (Radionica čvorova i konopca)
                new ActivityRegistration { Id = 95, ActivityId = 7, MemberId = 17, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-6) },
                new ActivityRegistration { Id = 96, ActivityId = 7, MemberId = 19, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-5) },
                new ActivityRegistration { Id = 97, ActivityId = 7, MemberId = 21, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-4) },
                new ActivityRegistration { Id = 98, ActivityId = 7, MemberId = 23, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-3) },
                
                // Activity 9 (Turnir u stolnom tenisu)
                new ActivityRegistration { Id = 99, ActivityId = 9, MemberId = 17, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 100, ActivityId = 9, MemberId = 19, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-1) },
                new ActivityRegistration { Id = 101, ActivityId = 9, MemberId = 21, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now },
                new ActivityRegistration { Id = 102, ActivityId = 9, MemberId = 23, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now },
            };
            modelBuilder.Entity<ActivityRegistration>().HasData(additionalActivityRegistrations);

            var member7ActivityRegistrations = new List<ActivityRegistration>
            {
                new ActivityRegistration { Id = 103, ActivityId = 2, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-22) },
                new ActivityRegistration { Id = 104, ActivityId = 5, MemberId = 7, Status = RegistrationStatus.Approved, RegisteredAt = DateTime.Now.AddDays(-16) },
                new ActivityRegistration { Id = 105, ActivityId = 12, MemberId = 7, Status = RegistrationStatus.Completed, RegisteredAt = DateTime.Now.AddDays(-20) },
                
                new ActivityRegistration { Id = 115, ActivityId = 11, MemberId = 7, Status = RegistrationStatus.Rejected, RegisteredAt = DateTime.Now.AddDays(-12) },
                new ActivityRegistration { Id = 116, ActivityId = 13, MemberId = 7, Status = RegistrationStatus.Rejected, RegisteredAt = DateTime.Now.AddDays(-8) },
                new ActivityRegistration { Id = 117, ActivityId = 14, MemberId = 7, Status = RegistrationStatus.Rejected, RegisteredAt = DateTime.Now.AddDays(-5) },
                
                new ActivityRegistration { Id = 118, ActivityId = 15, MemberId = 7, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-3) },
                new ActivityRegistration { Id = 119, ActivityId = 21, MemberId = 7, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-2) },
                new ActivityRegistration { Id = 120, ActivityId = 22, MemberId = 7, Status = RegistrationStatus.Pending, RegisteredAt = DateTime.Now.AddDays(-8) },
            };
            modelBuilder.Entity<ActivityRegistration>().HasData(member7ActivityRegistrations);


            // Seed Post Images (only for finished activities)
            var postImages = new List<PostImage>
            {
                // Images for Activity 3 posts
                new PostImage { Id = 1, PostId = 1, ImageUrl = "/images/posts/football_tournament_1.jpg", UploadedAt = DateTime.Now.AddDays(-1), IsCoverPhoto = true },
                new PostImage { Id = 2, PostId = 1, ImageUrl = "/images/posts/football_tournament_2.jpg", UploadedAt = DateTime.Now.AddDays(-1), IsCoverPhoto = false },
                new PostImage { Id = 3, PostId = 2, ImageUrl = "/images/posts/football_tournament_3.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(2), IsCoverPhoto = true },
                new PostImage { Id = 4, PostId = 3, ImageUrl = "/images/posts/football_tournament_4.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(4), IsCoverPhoto = true },
                // Images for Activity 12 posts
                new PostImage { Id = 5, PostId = 4, ImageUrl = "/images/posts/mostar_walk_1.jpg", UploadedAt = DateTime.Now.AddDays(-1), IsCoverPhoto = true },
                new PostImage { Id = 6, PostId = 4, ImageUrl = "/images/posts/mostar_walk_2.jpg", UploadedAt = DateTime.Now.AddDays(-1), IsCoverPhoto = false },
                new PostImage { Id = 7, PostId = 5, ImageUrl = "/images/posts/old_bridge_mostar.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(1), IsCoverPhoto = true },
                new PostImage { Id = 8, PostId = 6, ImageUrl = "/images/posts/koski_mehmed_pasha_mosque.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(3), IsCoverPhoto = true }
            };
            modelBuilder.Entity<PostImage>().HasData(postImages);

            // Seed Likes (only for finished activities)
            var likes = new List<Like>
            {
                // Likes for Activity 3 posts
                new Like { Id = 1, PostId = 1, CreatedById = 8, LikedAt = DateTime.Now.AddDays(-1).AddHours(1) },
                new Like { Id = 2, PostId = 1, CreatedById = 12, LikedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Like { Id = 3, PostId = 1, CreatedById = 10, LikedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Like { Id = 4, PostId = 2, CreatedById = 7, LikedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Like { Id = 5, PostId = 2, CreatedById = 10, LikedAt = DateTime.Now.AddDays(-1).AddHours(4) },
                new Like { Id = 6, PostId = 2, CreatedById = 13, LikedAt = DateTime.Now.AddDays(-1).AddHours(5) },
                new Like { Id = 7, PostId = 3, CreatedById = 8, LikedAt = DateTime.Now.AddDays(-1).AddHours(5) },
                new Like { Id = 8, PostId = 3, CreatedById = 11, LikedAt = DateTime.Now.AddDays(-1).AddHours(6) },
                new Like { Id = 9, PostId = 3, CreatedById = 14, LikedAt = DateTime.Now.AddDays(-1).AddHours(7) },
                // Likes for Activity 12 posts
                new Like { Id = 10, PostId = 4, CreatedById = 7, LikedAt = DateTime.Now.AddDays(-1).AddHours(1) },
                new Like { Id = 11, PostId = 4, CreatedById = 10, LikedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Like { Id = 12, PostId = 4, CreatedById = 13, LikedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Like { Id = 13, PostId = 5, CreatedById = 8, LikedAt = DateTime.Now.AddDays(-1).AddHours(2) },
                new Like { Id = 14, PostId = 5, CreatedById = 12, LikedAt = DateTime.Now.AddDays(-1).AddHours(3) },
                new Like { Id = 15, PostId = 5, CreatedById = 15, LikedAt = DateTime.Now.AddDays(-1).AddHours(4) },
                new Like { Id = 16, PostId = 6, CreatedById = 7, LikedAt = DateTime.Now.AddDays(-1).AddHours(4) },
                new Like { Id = 17, PostId = 6, CreatedById = 9, LikedAt = DateTime.Now.AddDays(-1).AddHours(5) },
                new Like { Id = 18, PostId = 6, CreatedById = 11, LikedAt = DateTime.Now.AddDays(-1).AddHours(6) }
            };
            modelBuilder.Entity<Like>().HasData(likes);


            // Seed Reviews
            var reviews = new List<Review>
            {
                new Review { Id = 1, ActivityId = 3, MemberId = 11, Rating = 4, Content = "Zabavno i takmičarski duh!", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 2, ActivityId = 3, MemberId = 17, Rating = 5, Content = "Fudbalski turnir je bio odličan! Tim 'Bregava' je zasluženo pobijedio.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 3, ActivityId = 3, MemberId = 19, Rating = 4, Content = "Super organizacija turnira. Naučio sam puno o timskom radu.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 4, ActivityId = 3, MemberId = 21, Rating = 5, Content = "Odličan turnir! Vidio sam mnoge dobre igre.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 5, ActivityId = 12, MemberId = 17, Rating = 5, Content = "Mostarska šetnja je bila fascinantna! Posjetili smo Stari Most.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 6, ActivityId = 12, MemberId = 19, Rating = 4, Content = "Prekrasna povijesna šetnja kroz Mostar.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 7, ActivityId = 12, MemberId = 21, Rating = 5, Content = "Naučio sam puno o povijesti Mostara. Preporučujem svima!", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 8, ActivityId = 19, MemberId = 17, Rating = 5, Content = "Turnir u košarci je bio fantastičan! Tim 'Bregava Eagles' je zasluženo pobijedio.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 9, ActivityId = 19, MemberId = 19, Rating = 4, Content = "Odličan turnir! Naučio sam puno o timskom radu i strategiji.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 10, ActivityId = 19, MemberId = 21, Rating = 5, Content = "Košarka je stvarno zabavna! Već se radujem sljedećem turniru.", CreatedAt = DateTime.Now.AddDays(-1) },
                new Review { Id = 11, ActivityId = 19, MemberId = 23, Rating = 4, Content = "Dobar turnir s odličnom organizacijom.", CreatedAt = DateTime.Now.AddDays(-1) }
            };
            modelBuilder.Entity<Review>().HasData(reviews);

            // Seed More Notifications
            var moreNotifications = new List<Notification>
            {
                new Notification { Id = 1, Message = "Vaša registracija za aktivnost 'Jesenji kamp u Jahorini' je odobrena!", ReceiverId = 7, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-3), IsRead = true },
                new Notification { Id = 2, Message = "Nova aktivnost 'Šetnja kroz Sutjesku' je dostupna za registraciju.", ReceiverId = 8, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-2), IsRead = false },
                new Notification { Id = 3, Message = "Ana Marić je poslala zahtjev za prijateljstvo.", ReceiverId = 7, SenderId = 8, CreatedAt = DateTime.Now.AddDays(-30), IsRead = true },
                new Notification { Id = 4, Message = "Vaša registracija za aktivnost 'Fudbalski turnir' je odobrena!", ReceiverId = 11, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-5), IsRead = true },
                new Notification { Id = 5, Message = "Nova aktivnost 'Čišćenje rijeke Bosne' je dostupna za registraciju.", ReceiverId = 16, SenderId = 1, CreatedAt = DateTime.Now, IsRead = false },
                new Notification { Id = 6, Message = "Vaša registracija za aktivnost 'Zimski kamp u Kozari' je odobrena!", ReceiverId = 7, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-7), IsRead = true },
                new Notification { Id = 7, Message = "Vaša registracija za aktivnost 'Radionica čvorova i konopca' je odobrena!", ReceiverId = 7, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-5), IsRead = true },
                new Notification { Id = 8, Message = "Marko Petrović je lajkao vaš post o kampu u Jahorini.", ReceiverId = 8, SenderId = 7, CreatedAt = DateTime.Now.AddDays(-1).AddHours(1), IsRead = false },
                new Notification { Id = 9, Message = "Ana Marić je komentirala vaš post o zimskom kampu.", ReceiverId = 7, SenderId = 8, CreatedAt = DateTime.Now.AddDays(-2).AddHours(2), IsRead = false },
                new Notification { Id = 10, Message = "Nova aktivnost 'Turnir u stolnom tenisu' je dostupna za registraciju.", ReceiverId = 7, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-3), IsRead = true }
            };
            modelBuilder.Entity<Notification>().HasData(moreNotifications);

            // Seed Documents
            var documents = new List<Document>
            {
                new Document
                {
                    Id = 1,
                    Title = "Izviđački propisi i pravila",
                    FilePath = "/documents/scout_rules_and_regulations.docx",
                    CreatedAt = DateTime.Now.AddDays(-30),
                    AdminId = 1
                },
                new Document
                {
                    Id = 2,
                    Title = "Prva pomoć - osnovni vodič",
                    FilePath = "/documents/first_aid_basic_guide.docx",
                    CreatedAt = DateTime.Now.AddDays(-20),
                    AdminId = 1
                },
                new Document
                {
                    Id = 3,
                    Title = "Orijentacija i navigacija",
                    FilePath = "/documents/orientation_and_navigation.docx",
                    CreatedAt = DateTime.Now.AddDays(-15),
                    AdminId = 1
                },
                new Document
                {
                    Id = 4,
                    Title = "Izviđački čvorovi - ilustrovani vodič",
                    FilePath = "/documents/scout_knots_illustrated_guide.docx",
                    CreatedAt = DateTime.Now.AddDays(-8),
                    AdminId = 1
                },
                new Document
                {
                    Id = 5,
                    Title = "Preživljavanje u prirodi",
                    FilePath = "/documents/wilderness_survival.docx",
                    CreatedAt = DateTime.Now.AddDays(-5),
                    AdminId = 1
                },
                new Document
                {
                    Id = 6,
                    Title = "Planiranje aktivnosti",
                    FilePath = "/documents/activity_planning_guide.docx",
                    CreatedAt = DateTime.Now.AddDays(-2),
                    AdminId = 1
                },
                new Document
                {
                    Id = 7,
                    Title = "Izviđački kodeks ponašanja",
                    FilePath = "/documents/scout_code_of_conduct.docx",
                    CreatedAt = DateTime.Now.AddDays(-1),
                    AdminId = 1
                }
            };
            modelBuilder.Entity<Document>().HasData(documents);

            var troop2MemberIds = new List<int> { 7, 17, 18, 19, 20, 21, 22, 23, 24 };
            var extraNotifications = new List<Notification>
            {
                new Notification { Id = 21, Message = "Vaš član je postao vođa aktivnosti 'Izviđački izazov 1'.", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-4), IsRead = true },
                new Notification { Id = 22, Message = "Troop 'Bregava' je dodan u novi kamp! Pripremite plan aktivnosti.", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-6), IsRead = true },
                new Notification { Id = 23, Message = "Obavijest: Registracija tima za 'Turnir u košarci' je uspješna.", ReceiverId = 2, SenderId = 17, CreatedAt = DateTime.Now.AddDays(-2), IsRead = true },
                new Notification { Id = 24, Message = "Novi član se pridružio odredu 'Bregava'.", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-8), IsRead = true },
                new Notification { Id = 25, Message = "Vaša oprema je odobrena za korištenje na sljedećoj aktivnosti.", ReceiverId = 2, SenderId = 18, CreatedAt = DateTime.Now.AddDays(-3), IsRead = false },
                new Notification { Id = 26, Message = "Čestitamo! Troop 'Bregava' je ostvario najviše bodova na radionici.", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-1), IsRead = false },
                new Notification { Id = 27, Message = "Dodana nova nagrada za vaš odred - pogledajte detalje.", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-7), IsRead = false },
                new Notification { Id = 28, Message = "Nova edukativna obuka dostupna za sve članove odreda.", ReceiverId = 2, SenderId = 19, CreatedAt = DateTime.Now.AddDays(-5), IsRead = false },
                new Notification { Id = 29, Message = "Zabilježen zapažen doprinos na 'Čišćenje rijeke Bosne'. Hvala timu 'Bregava'!", ReceiverId = 2, SenderId = 1, CreatedAt = DateTime.Now.AddDays(-9), IsRead = false },
            };
            modelBuilder.Entity<Notification>().HasData(extraNotifications);

            var extraActivities = new List<Activity>
            {
                new Activity
                {
                    Id = 40,
                    Title = "Izviđački izazov 1",
                    Description = "Tim-building izazov na otvorenom za sve uzraste.",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(10),
                    EndTime = DateTime.Now.AddDays(10).AddHours(5),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Park Stolac",
                    Fee = 0,
                    CreatedAt = DateTime.Now,
                    TroopId = 2,
                    ActivityTypeId = 2,
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "images/activities/izazov_1.jpg"
                },
                new Activity
                {
                    Id = 41,
                    Title = "Izviđački izazov 2",
                    Description = "Avanturistička igra orijentacije oko rijeke Bregave.",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(18),
                    EndTime = DateTime.Now.AddDays(18).AddHours(6),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Obala Bregave, Stolac",
                    Fee = 5,
                    CreatedAt = DateTime.Now,
                    TroopId = 2,
                    ActivityTypeId = 4,
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "images/activities/izazov_2.jpg"
                },
                new Activity
                {
                    Id = 42,
                    Title = "Izviđački izazov 3",
                    Description = "Sportski izazovi i takmičarske igre.",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(22),
                    EndTime = DateTime.Now.AddDays(22).AddHours(8),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Sportski centar Stolac",
                    Fee = 10,
                    CreatedAt = DateTime.Now,
                    TroopId = 2,
                    ActivityTypeId = 3,
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "images/activities/izazov_3.jpg"
                },
                new Activity
                {
                    Id = 43,
                    Title = "Izviđački izazov 4",
                    Description = "Izlet i edukativna radionica o zaštiti okoliša.",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(26),
                    EndTime = DateTime.Now.AddDays(26).AddHours(4),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Eko zona Stolac",
                    Fee = 0,
                    CreatedAt = DateTime.Now,
                    TroopId = 2,
                    ActivityTypeId = 6,
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "images/activities/izazov_4.jpg"
                },
                new Activity
                {
                    Id = 44,
                    Title = "Izviđački izazov 5",
                    Description = "Kampovanje pod zvijezdama s noćnom igrom.",
                    isPrivate = false,
                    StartTime = DateTime.Now.AddDays(34),
                    EndTime = DateTime.Now.AddDays(35),
                    Latitude = 43.0597,
                    Longitude = 17.9444,
                    LocationName = "Kamp zona Stolac",
                    Fee = 15,
                    CreatedAt = DateTime.Now,
                    TroopId = 2,
                    ActivityTypeId = 1,
                    ActivityState = "RegistrationsOpenActivityState",
                    ImagePath = "images/activities/izazov_5.jpg"
                }
            };
            modelBuilder.Entity<Activity>().HasData(extraActivities);

            var additionalPostImages = new List<PostImage>
            {
                // For post 7
                new PostImage { Id = 41, PostId = 7, ImageUrl = "/images/posts/izazov1.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(1), IsCoverPhoto = true },
                new PostImage { Id = 42, PostId = 7, ImageUrl = "/images/posts/izazov1_extra.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(2), IsCoverPhoto = false },
                // For post 8
                new PostImage { Id = 43, PostId = 8, ImageUrl = "/images/posts/izazov2.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(2), IsCoverPhoto = true },
                // For post 9
                new PostImage { Id = 44, PostId = 9, ImageUrl = "/images/posts/izazov3.jpg", UploadedAt = DateTime.Now.AddDays(-1).AddHours(3), IsCoverPhoto = true }
            };
            modelBuilder.Entity<PostImage>().HasData(additionalPostImages);
        }
    }
}
