// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoutBadge _$ScoutBadgeFromJson(Map<String, dynamic> json) => ScoutBadge(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  description: json['description'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  totalMemberBadges: (json['totalMemberBadges'] as num?)?.toInt() ?? 0,
  completedMemberBadges: (json['completedMemberBadges'] as num?)?.toInt() ?? 0,
  inProgressMemberBadges:
      (json['inProgressMemberBadges'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ScoutBadgeToJson(ScoutBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'totalMemberBadges': instance.totalMemberBadges,
      'completedMemberBadges': instance.completedMemberBadges,
      'inProgressMemberBadges': instance.inProgressMemberBadges,
    };
