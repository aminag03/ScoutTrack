// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeRequirement _$BadgeRequirementFromJson(Map<String, dynamic> json) =>
    BadgeRequirement(
      id: (json['id'] as num).toInt(),
      badgeId: (json['badgeId'] as num).toInt(),
      badgeName: json['badgeName'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BadgeRequirementToJson(BadgeRequirement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'badgeId': instance.badgeId,
      'badgeName': instance.badgeName,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
