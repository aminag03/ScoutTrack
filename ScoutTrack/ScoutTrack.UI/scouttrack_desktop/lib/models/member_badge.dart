import 'package:json_annotation/json_annotation.dart';

part 'member_badge.g.dart';

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
  final int status;
  final DateTime? completedAt;
  final DateTime createdAt;

  MemberBadge({
    this.id = 0,
    this.memberId = 0,
    this.memberFirstName = '',
    this.memberLastName = '',
    this.memberProfilePictureUrl = '',
    this.badgeId = 0,
    this.badgeName = '',
    this.badgeImageUrl = '',
    this.status = 0,
    this.completedAt,
    required this.createdAt,
  });

  factory MemberBadge.fromJson(Map<String, dynamic> json) => _$MemberBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$MemberBadgeToJson(this);

  String get memberFullName => '$memberFirstName $memberLastName';
}
