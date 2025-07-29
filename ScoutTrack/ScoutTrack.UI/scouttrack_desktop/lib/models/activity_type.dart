import 'package:json_annotation/json_annotation.dart';

part 'activity_type.g.dart';

@JsonSerializable()
class ActivityType {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ActivityType({
    this.id = 0,
    this.name = '',
    this.description = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTypeToJson(this);
}
