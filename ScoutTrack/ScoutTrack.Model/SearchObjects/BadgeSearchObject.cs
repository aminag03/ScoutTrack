using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.SearchObjects
{
    public class BadgeSearchObject : BaseSearchObject
    {
        public string Name { get; set; } = string.Empty;
        public int? TroopId { get; set; }
    }
}
