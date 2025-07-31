// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityEquipment _$ActivityEquipmentFromJson(Map<String, dynamic> json) =>
    ActivityEquipment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      activityId: (json['activityId'] as num).toInt(),
      equipmentId: (json['equipmentId'] as num).toInt(),
      equipmentName: json['equipmentName'] as String? ?? '',
      equipmentDescription: json['equipmentDescription'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ActivityEquipmentToJson(ActivityEquipment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'equipmentId': instance.equipmentId,
      'equipmentName': instance.equipmentName,
      'equipmentDescription': instance.equipmentDescription,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
