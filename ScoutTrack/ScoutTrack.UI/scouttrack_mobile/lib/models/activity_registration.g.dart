// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityRegistration _$ActivityRegistrationFromJson(
  Map<String, dynamic> json,
) => ActivityRegistration(
  id: (json['id'] as num).toInt(),
  registeredAt: DateTime.parse(json['registeredAt'] as String),
  activityId: (json['activityId'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  notes: json['notes'] as String,
  activityTitle: json['activityTitle'] as String,
  memberName: json['memberName'] as String,
  activityDescription: json['activityDescription'] as String,
  activityLocationName: json['activityLocationName'] as String,
  activityTypeName: json['activityTypeName'] as String,
  activityState: json['activityState'] as String,
  activityStartTime: json['activityStartTime'] == null
      ? null
      : DateTime.parse(json['activityStartTime'] as String),
  activityEndTime: json['activityEndTime'] == null
      ? null
      : DateTime.parse(json['activityEndTime'] as String),
  activityFee: (json['activityFee'] as num).toDouble(),
  activityImagePath: json['activityImagePath'] as String,
  troopId: (json['troopId'] as num).toInt(),
  troopName: json['troopName'] as String,
  activityTypeId: (json['activityTypeId'] as num).toInt(),
);

Map<String, dynamic> _$ActivityRegistrationToJson(
  ActivityRegistration instance,
) => <String, dynamic>{
  'id': instance.id,
  'registeredAt': instance.registeredAt.toIso8601String(),
  'activityId': instance.activityId,
  'memberId': instance.memberId,
  'status': instance.status,
  'notes': instance.notes,
  'activityTitle': instance.activityTitle,
  'memberName': instance.memberName,
  'activityDescription': instance.activityDescription,
  'activityLocationName': instance.activityLocationName,
  'activityTypeName': instance.activityTypeName,
  'activityState': instance.activityState,
  'activityStartTime': instance.activityStartTime?.toIso8601String(),
  'activityEndTime': instance.activityEndTime?.toIso8601String(),
  'activityFee': instance.activityFee,
  'activityImagePath': instance.activityImagePath,
  'troopId': instance.troopId,
  'troopName': instance.troopName,
  'activityTypeId': instance.activityTypeId,
};
