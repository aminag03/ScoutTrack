using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Services.Database.Entities
{
    public class Admin : UserAccount
    {
        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;
        public List<Document> Documents { get; set; } = new List<Document>();
    }
}