using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class CityUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
    }
} 