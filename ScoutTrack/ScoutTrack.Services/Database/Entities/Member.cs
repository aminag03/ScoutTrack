using ScoutTrack.Services.Database.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Member : UserAccount
    {
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        public DateTime BirthDate { get; set; }

        public Gender Gender { get; set; }
        public string? ProfilePictureUrl { get; set; }

        [ForeignKey(nameof(Troop))]
        public int TroopId { get; set; }
        public Troop Troop { get; set; } = null!;

        [ForeignKey(nameof(City))]
        public int CityId { get; set; }
        public City City { get; set; } = null!;

        public ICollection<Activity> Activities { get; set; } = new List<Activity>();
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<ActivityRegistration> ActivityRegistrations { get; set; } = new List<ActivityRegistration>();
        public ICollection<MemberBadge> Badges { get; set; } = new List<MemberBadge>();
    }
}
