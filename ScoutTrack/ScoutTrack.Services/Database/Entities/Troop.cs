using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Troop : User
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

        public string LogoUrl { get; set; } = string.Empty;
        public ICollection<Member> Members { get; set; } = new List<Member>();
        public ICollection<Activity> Activities { get; set; } = new List<Activity>();
    }
}