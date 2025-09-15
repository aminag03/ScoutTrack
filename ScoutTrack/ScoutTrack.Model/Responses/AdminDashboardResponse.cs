using System;
using System.Collections.Generic;

namespace ScoutTrack.Model.Responses
{
    public class AdminDashboardResponse
    {
        public int TroopCount { get; set; }
        public int MemberCount { get; set; }
        public int ActivityCount { get; set; }
        public int PostCount { get; set; }
        public List<MostActiveTroopResponse> MostActiveTroops { get; set; } = new List<MostActiveTroopResponse>();
        public List<MonthlyActivityResponse> MonthlyActivities { get; set; } = new List<MonthlyActivityResponse>();
        public List<MonthlyAttendanceResponse> MonthlyAttendance { get; set; } = new List<MonthlyAttendanceResponse>();
        public List<ScoutCategoryResponse> ScoutCategories { get; set; } = new List<ScoutCategoryResponse>();
        public List<int> AvailableYears { get; set; } = new List<int>();
    }

    public class MostActiveTroopResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int ActivityCount { get; set; }
        public string CityName { get; set; } = string.Empty;
    }

    public class MonthlyActivityResponse
    {
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public int ActivityCount { get; set; }
        public int Year { get; set; }
    }

    public class ScoutCategoryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int MemberCount { get; set; }
        public double Percentage { get; set; }
        public string Color { get; set; } = string.Empty;
    }
}
