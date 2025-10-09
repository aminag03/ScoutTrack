// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberBadge _$MemberBadgeFromJson(Map<String, dynamic> json) => MemberBadge(
  id: (json['id'] as num?)?.toInt() ?? 0,
  memberId: (json['memberId'] as num?)?.toInt() ?? 0,
  memberFirstName: json['memberFirstName'] as String? ?? '',
  memberLastName: json['memberLastName'] as String? ?? '',
  memberProfilePictureUrl: json['memberProfilePictureUrl'] as String? ?? '',
  badgeId: (json['badgeId'] as num?)?.toInt() ?? 0,
  badgeName: json['badgeName'] as String? ?? '',
  badgeImageUrl: json['badgeImageUrl'] as String? ?? '',
  status:
      $enumDecodeNullable(_$MemberBadgeStatusEnumMap, json['status']) ??
      MemberBadgeStatus.inProgress,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MemberBadgeToJson(MemberBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'memberFirstName': instance.memberFirstName,
      'memberLastName': instance.memberLastName,
      'memberProfilePictureUrl': instance.memberProfilePictureUrl,
      'badgeId': instance.badgeId,
      'badgeName': instance.badgeName,
      'badgeImageUrl': instance.badgeImageUrl,
      'status': _$MemberBadgeStatusEnumMap[instance.status]!,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MemberBadgeStatusEnumMap = {
  MemberBadgeStatus.inProgress: 0,
  MemberBadgeStatus.completed: 1,
};
