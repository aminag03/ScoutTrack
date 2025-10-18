// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'troop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Troop _$TroopFromJson(Map<String, dynamic> json) => Troop(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
  name: json['name'] as String? ?? '',
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
  contactPhone: json['contactPhone'] as String? ?? '',
  logoUrl: json['logoUrl'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  scoutMaster: json['scoutMaster'] as String? ?? '',
  troopLeader: json['troopLeader'] as String? ?? '',
  foundingDate: DateTime.parse(json['foundingDate'] as String),
);

Map<String, dynamic> _$TroopToJson(Troop instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'name': instance.name,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'contactPhone': instance.contactPhone,
  'logoUrl': instance.logoUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'memberCount': instance.memberCount,
  'scoutMaster': instance.scoutMaster,
  'troopLeader': instance.troopLeader,
  'foundingDate': instance.foundingDate.toIso8601String(),
};
