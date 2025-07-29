// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityType _$ActivityTypeFromJson(Map<String, dynamic> json) => ActivityType(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ActivityTypeToJson(ActivityType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
