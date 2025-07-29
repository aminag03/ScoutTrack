using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.Responses
{
    public class CurrentUserResponse
    {
        public int Id { get; set; }
        public string Role { get; set; } = "";
        public string Username { get; set; } = "";
        public string? Email { get; set; }
        public string? CityName { get; set; }
        public string? TroopName { get; set; }
    }

}
