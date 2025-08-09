// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  isPrivate: json['isPrivate'] as bool? ?? false,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
  locationName: json['locationName'] as String? ?? '',
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  fee: (json['fee'] as num?)?.toDouble() ?? 0,
  troopId: (json['troopId'] as num).toInt(),
  troopName: json['troopName'] as String? ?? '',
  activityTypeId: (json['activityTypeId'] as num).toInt(),
  activityTypeName: json['activityTypeName'] as String? ?? '',
  activityState: json['activityState'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  registrationCount: (json['registrationCount'] as num?)?.toInt() ?? 0,
  imagePath: json['imagePath'] as String? ?? '',
  summary: json['summary'] as String? ?? '',
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isPrivate': instance.isPrivate,
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'locationName': instance.locationName,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'fee': instance.fee,
  'troopId': instance.troopId,
  'troopName': instance.troopName,
  'activityTypeId': instance.activityTypeId,
  'activityTypeName': instance.activityTypeName,
  'activityState': instance.activityState,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'registrationCount': instance.registrationCount,
  'imagePath': instance.imagePath,
  'summary': instance.summary,
};
