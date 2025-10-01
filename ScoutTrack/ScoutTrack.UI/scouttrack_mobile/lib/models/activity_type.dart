import 'package:json_annotation/json_annotation.dart';

part 'activity_type.g.dart';

@JsonSerializable()
class ActivityType {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int activityCount;

  ActivityType({
    this.id = 0,
    this.name = '',
    this.description = '',
    required this.createdAt,
    this.updatedAt,
    this.activityCount = 0,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTypeToJson(this);
}
