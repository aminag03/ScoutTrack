using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Activity
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        public bool isPrivate { get; set; }

        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }

        [Required]
        public double Latitude { get; set; }

        [Required]
        public double Longitude { get; set; }

        public string LocationName { get; set; } = string.Empty;

        [ForeignKey(nameof(City))]
        public int? CityId { get; set; }
        public City? City { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal? Fee { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey(nameof(Troop))]
        public int TroopId { get; set; }
        public Troop Troop { get; set; } = null!;

        [ForeignKey(nameof(ActivityType))]
        public int ActivityTypeId { get; set; }
        public ActivityType ActivityType { get; set; } = null!;

        public string ImagePath { get; set; } = string.Empty;

        public ICollection<Member> Participants { get; set; } = new List<Member>();
        public ICollection<ActivityRegistration> Registrations { get; set; } = new List<ActivityRegistration>();
        public ICollection<Post> Posts { get; set; } = new List<Post>();
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<ActivityEquipment> EquipmentList { get; set; } = new List<ActivityEquipment>();

        [MaxLength(1000)]
        public string ActivityState { get; set; } = string.Empty;
    }
}
