class TroopDashboard {
  final int memberCount;
  final int pendingRegistrationCount;
  final int activityCount;
  final List<UpcomingActivity> upcomingActivities;
  final List<MostActiveMember> mostActiveMembers;
  final List<MonthlyAttendance> monthlyAttendance;
  final List<int> availableYears;

  TroopDashboard({
    required this.memberCount,
    required this.pendingRegistrationCount,
    required this.activityCount,
    required this.upcomingActivities,
    required this.mostActiveMembers,
    required this.monthlyAttendance,
    required this.availableYears,
  });

  factory TroopDashboard.fromJson(Map<String, dynamic> json) {
    return TroopDashboard(
      memberCount: json['memberCount'] ?? 0,
      pendingRegistrationCount: json['pendingRegistrationCount'] ?? 0,
      activityCount: json['activityCount'] ?? 0,
      upcomingActivities:
          (json['upcomingActivities'] as List<dynamic>?)
              ?.map((e) => UpcomingActivity.fromJson(e))
              .toList() ??
          [],
      mostActiveMembers:
          (json['mostActiveMembers'] as List<dynamic>?)
              ?.map((e) => MostActiveMember.fromJson(e))
              .toList() ??
          [],
      monthlyAttendance:
          (json['monthlyAttendance'] as List<dynamic>?)
              ?.map((e) => MonthlyAttendance.fromJson(e))
              .toList() ??
          [],
      availableYears:
          (json['availableYears'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

class UpcomingActivity {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  final String activityTypeName;
  final double fee;
  final String imagePath;

  UpcomingActivity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.activityTypeName,
    required this.fee,
    required this.imagePath,
  });

  factory UpcomingActivity.fromJson(Map<String, dynamic> json) {
    return UpcomingActivity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      locationName: json['locationName'] ?? '',
      activityTypeName: json['activityTypeName'] ?? '',
      fee: (json['fee'] ?? 0).toDouble(),
      imagePath: json['imagePath'] ?? '',
    );
  }
}

class MostActiveMember {
  final int id;
  final String firstName;
  final String lastName;
  final int activityCount;
  final int postCount;
  final String profilePictureUrl;

  String get fullName => '$firstName $lastName';

  MostActiveMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.activityCount,
    required this.postCount,
    required this.profilePictureUrl,
  });

  factory MostActiveMember.fromJson(Map<String, dynamic> json) {
    return MostActiveMember(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      activityCount: json['activityCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      profilePictureUrl: json['profilePictureUrl'] ?? '',
    );
  }
}

class MonthlyAttendance {
  final int month;
  final String monthName;
  final double averageAttendance;
  final int year;

  MonthlyAttendance({
    required this.month,
    required this.monthName,
    required this.averageAttendance,
    required this.year,
  });

  factory MonthlyAttendance.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendance(
      month: json['month'] ?? 0,
      monthName: json['monthName'] ?? '',
      averageAttendance: (json['averageAttendance'] ?? 0).toDouble(),
      year: json['year'] ?? 0,
    );
  }
}
