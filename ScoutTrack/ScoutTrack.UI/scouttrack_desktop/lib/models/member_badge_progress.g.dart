// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_badge_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberBadgeProgress _$MemberBadgeProgressFromJson(Map<String, dynamic> json) =>
    MemberBadgeProgress(
      id: (json['id'] as num?)?.toInt() ?? 0,
      memberBadgeId: (json['memberBadgeId'] as num?)?.toInt() ?? 0,
      requirementId: (json['requirementId'] as num?)?.toInt() ?? 0,
      requirementDescription: json['requirementDescription'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$MemberBadgeProgressToJson(
  MemberBadgeProgress instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberBadgeId': instance.memberBadgeId,
  'requirementId': instance.requirementId,
  'requirementDescription': instance.requirementDescription,
  'isCompleted': instance.isCompleted,
  'completedAt': instance.completedAt?.toIso8601String(),
};
