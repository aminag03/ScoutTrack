using System.ComponentModel.DataAnnotations;

namespace ScoutTrack.Model.Requests
{
    public class CityUpsertRequest
    {
        [Required]
        [MaxLength(100, ErrorMessage = "Name must not exceed 100 characters.")]
        [RegularExpression(@"^[A-Za-zÈèÆæĞğŠš\s'-]+$", ErrorMessage = "City name contains invalid characters.")]
        public string Name { get; set; } = string.Empty;
    }
} 