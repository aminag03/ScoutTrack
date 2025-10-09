import 'package:json_annotation/json_annotation.dart';

part 'badge_requirement.g.dart';

@JsonSerializable()
class BadgeRequirement {
  final int id;
  final int badgeId;
  final String badgeName;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BadgeRequirement({
    this.id = 0,
    this.badgeId = 0,
    this.badgeName = '',
    this.description = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory BadgeRequirement.fromJson(Map<String, dynamic> json) =>
      _$BadgeRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeRequirementToJson(this);
}
