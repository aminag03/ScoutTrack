class AdminDashboard {
  final int troopCount;
  final int memberCount;
  final int activityCount;
  final int postCount;
  final List<MostActiveTroop> mostActiveTroops;
  final List<MonthlyActivity> monthlyActivities;
  final List<MonthlyAttendance> monthlyAttendance;
  final List<ScoutCategory> scoutCategories;
  final List<int> availableYears;

  AdminDashboard({
    required this.troopCount,
    required this.memberCount,
    required this.activityCount,
    required this.postCount,
    required this.mostActiveTroops,
    required this.monthlyActivities,
    required this.monthlyAttendance,
    required this.scoutCategories,
    required this.availableYears,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      troopCount: json['troopCount'] ?? 0,
      memberCount: json['memberCount'] ?? 0,
      activityCount: json['activityCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      mostActiveTroops:
          (json['mostActiveTroops'] as List<dynamic>?)
              ?.map((x) => MostActiveTroop.fromJson(x))
              .toList() ??
          [],
      monthlyActivities:
          (json['monthlyActivities'] as List<dynamic>?)
              ?.map((x) => MonthlyActivity.fromJson(x))
              .toList() ??
          [],
      monthlyAttendance:
          (json['monthlyAttendance'] as List<dynamic>?)
              ?.map((x) => MonthlyAttendance.fromJson(x))
              .toList() ??
          [],
      scoutCategories:
          (json['scoutCategories'] as List<dynamic>?)
              ?.map((x) => ScoutCategory.fromJson(x))
              .toList() ??
          [],
      availableYears:
          (json['availableYears'] as List<dynamic>?)
              ?.map((x) => x as int)
              .toList() ??
          [],
    );
  }
}

class MostActiveTroop {
  final int id;
  final String name;
  final int activityCount;
  final String cityName;

  MostActiveTroop({
    required this.id,
    required this.name,
    required this.activityCount,
    required this.cityName,
  });

  factory MostActiveTroop.fromJson(Map<String, dynamic> json) {
    return MostActiveTroop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      activityCount: json['activityCount'] ?? 0,
      cityName: json['cityName'] ?? '',
    );
  }
}

class MonthlyActivity {
  final int month;
  final String monthName;
  final int activityCount;
  final int year;

  MonthlyActivity({
    required this.month,
    required this.monthName,
    required this.activityCount,
    required this.year,
  });

  factory MonthlyActivity.fromJson(Map<String, dynamic> json) {
    return MonthlyActivity(
      month: json['month'] ?? 0,
      monthName: json['monthName'] ?? '',
      activityCount: json['activityCount'] ?? 0,
      year: json['year'] ?? 0,
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
      averageAttendance: (json['averageAttendance'] ?? 0.0).toDouble(),
      year: json['year'] ?? 0,
    );
  }
}

class ScoutCategory {
  final int id;
  final String name;
  final int memberCount;
  final double percentage;
  String color;

  ScoutCategory({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.percentage,
    required this.color,
  });

  factory ScoutCategory.fromJson(Map<String, dynamic> json) {
    return ScoutCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      color: json['color'] ?? '#4F8055',
    );
  }
}
