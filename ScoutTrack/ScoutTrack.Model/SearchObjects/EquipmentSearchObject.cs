using System;
using System.Collections.Generic;
using System.Text;

namespace ScoutTrack.Model.SearchObjects
{
    public class EquipmentSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsGlobal { get; set; }
        public int? CreatedByTroopId { get; set; }
    }
}
