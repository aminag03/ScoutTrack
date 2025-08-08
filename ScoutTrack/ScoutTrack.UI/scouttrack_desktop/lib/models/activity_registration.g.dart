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
};
