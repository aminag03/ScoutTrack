import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable()
class Badge {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? totalMemberBadges;
  final int? completedMemberBadges;
  final int? inProgressMemberBadges;

  Badge({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.totalMemberBadges = 0,
    this.completedMemberBadges = 0,
    this.inProgressMemberBadges = 0,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}
