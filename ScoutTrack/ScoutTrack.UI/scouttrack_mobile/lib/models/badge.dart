import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable()
class ScoutBadge {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int totalMemberBadges;
  final int completedMemberBadges;
  final int inProgressMemberBadges;

  ScoutBadge({
    this.id = 0,
    this.name = '',
    this.imageUrl = '',
    this.description = '',
    required this.createdAt,
    this.updatedAt,
    this.totalMemberBadges = 0,
    this.completedMemberBadges = 0,
    this.inProgressMemberBadges = 0,
  });

  factory ScoutBadge.fromJson(Map<String, dynamic> json) =>
      _$ScoutBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$ScoutBadgeToJson(this);
}
