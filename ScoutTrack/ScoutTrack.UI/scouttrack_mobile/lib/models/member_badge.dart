import 'package:json_annotation/json_annotation.dart';

part 'member_badge.g.dart';

enum MemberBadgeStatus {
  @JsonValue(0)
  inProgress,
  @JsonValue(1)
  completed,
}

@JsonSerializable()
class MemberBadge {
  final int id;
  final int memberId;
  final String memberFirstName;
  final String memberLastName;
  final String memberProfilePictureUrl;
  final int badgeId;
  final String badgeName;
  final String badgeImageUrl;
  final MemberBadgeStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MemberBadge({
    this.id = 0,
    this.memberId = 0,
    this.memberFirstName = '',
    this.memberLastName = '',
    this.memberProfilePictureUrl = '',
    this.badgeId = 0,
    this.badgeName = '',
    this.badgeImageUrl = '',
    this.status = MemberBadgeStatus.inProgress,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory MemberBadge.fromJson(Map<String, dynamic> json) =>
      _$MemberBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$MemberBadgeToJson(this);
}
