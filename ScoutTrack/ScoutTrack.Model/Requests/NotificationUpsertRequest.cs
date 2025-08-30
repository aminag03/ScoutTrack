using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace ScoutTrack.Model.Requests
{
    public class NotificationUpsertRequest : IValidatableObject
    {
        [Required]
        [MaxLength(500, ErrorMessage = "Message cannot exceed 500 characters.")]
        public string Message { get; set; } = string.Empty;

        [Required]
        [MinLength(1, ErrorMessage = "At least one user ID is required.")]
        public List<int> UserIds { get; set; } = new List<int>();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (UserIds != null && UserIds.Any(id => id <= 0))
            {
                yield return new ValidationResult(
                    "All user IDs must be positive integers.",
                    new[] { nameof(UserIds) });
            }

            if (UserIds != null && UserIds.Count != UserIds.Distinct().Count())
            {
                yield return new ValidationResult(
                    "Duplicate user IDs are not allowed.",
                    new[] { nameof(UserIds) });
            }
        }
    }
}
