using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.Responses
{
    public class CityResponse
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int TroopCount { get; set; }
        public int MemberCount { get; set; }
    }
} 