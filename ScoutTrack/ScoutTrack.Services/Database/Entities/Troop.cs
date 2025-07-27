using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Troop : UserAccount
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [ForeignKey(nameof(City))]
        public int CityId { get; set; }
        public City? City { get; set; }

        [Required]
        public double Latitude { get; set; }

        [Required]
        public double Longitude { get; set; }

        [Phone]
        [MaxLength(20)]
        public string ContactPhone { get; set; } = string.Empty;

        [MaxLength(100)]
        public string ScoutMaster { get; set; } = string.Empty;  // Starješina

        [MaxLength(100)]
        public string TroopLeader { get; set; } = string.Empty;  // Načelnik

        public DateTime FoundingDate { get; set; } = DateTime.UtcNow;

        public string LogoUrl { get; set; } = string.Empty;
        public ICollection<Member> Members { get; set; } = new List<Member>();
        public ICollection<Activity> Activities { get; set; } = new List<Activity>();
    }
}