using System;
using System.Collections.Generic;

namespace ScoutTrack.Model.Responses
{
    public class TroopDashboardResponse
    {
        public int MemberCount { get; set; }
        public int PendingRegistrationCount { get; set; }
        public int ActivityCount { get; set; }
        public List<UpcomingActivityResponse> UpcomingActivities { get; set; } = new List<UpcomingActivityResponse>();
        public List<MostActiveMemberResponse> MostActiveMembers { get; set; } = new List<MostActiveMemberResponse>();
        public List<MonthlyAttendanceResponse> MonthlyAttendance { get; set; } = new List<MonthlyAttendanceResponse>();
        public List<int> AvailableYears { get; set; } = new List<int>();
    }

    public class UpcomingActivityResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public string ActivityTypeName { get; set; } = string.Empty;
        public decimal Fee { get; set; }
        public string ImagePath { get; set; } = string.Empty;
    }

    public class MostActiveMemberResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public int ActivityCount { get; set; }
        public int PostCount { get; set; }
        public string ProfilePictureUrl { get; set; } = string.Empty;
    }

    public class MonthlyAttendanceResponse
    {
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public double AverageAttendance { get; set; }
        public int Year { get; set; }
    }
}
