import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final int id;
  final String title;
  final String description;
  final bool isPrivate;
  final DateTime? startTime;
  final DateTime? endTime;
  final double latitude;
  final double longitude;
  final String locationName;
  final double fee;
  final int troopId;
  final String troopName;
  final int activityTypeId;
  final String activityTypeName;
  final String activityState;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int registrationCount;
  final int pendingRegistrationCount;
  final int approvedRegistrationCount;
  final String imagePath;
  final String summary;

  Activity({
    this.id = 0,
    this.title = '',
    this.description = '',
    this.isPrivate = false,
    this.startTime,
    this.endTime,
    this.latitude = 0,
    this.longitude = 0,
    this.locationName = '',
    this.fee = 0,
    required this.troopId,
    this.troopName = '',
    required this.activityTypeId,
    this.activityTypeName = '',
    this.activityState = '',
    required this.createdAt,
    this.updatedAt,
    this.registrationCount = 0,
    this.pendingRegistrationCount = 0,
    this.approvedRegistrationCount = 0,
    this.imagePath = '',
    this.summary = '',
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
