using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ScoutTrack.Model.Requests
{
    public class UserUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;

        [MaxLength(20)]
        [Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        [MinLength(8)]
        public string Password { get; set; } = string.Empty;
    }
}
