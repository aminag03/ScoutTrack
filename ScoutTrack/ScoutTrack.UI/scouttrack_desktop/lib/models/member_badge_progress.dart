import 'package:json_annotation/json_annotation.dart';

part 'member_badge_progress.g.dart';

@JsonSerializable()
class MemberBadgeProgress {
  final int id;
  final int memberBadgeId;
  final int requirementId;
  final String requirementDescription;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  MemberBadgeProgress({
    this.id = 0,
    this.memberBadgeId = 0,
    this.requirementId = 0,
    this.requirementDescription = '',
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  factory MemberBadgeProgress.fromJson(Map<String, dynamic> json) => _$MemberBadgeProgressFromJson(json);

  Map<String, dynamic> toJson() => _$MemberBadgeProgressToJson(this);
}
