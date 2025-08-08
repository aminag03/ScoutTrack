using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScoutTrack.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? ActivityId { get; set; }
        public int? MemberId { get; set; }
        public int? Rating { get; set; }
    }
}
