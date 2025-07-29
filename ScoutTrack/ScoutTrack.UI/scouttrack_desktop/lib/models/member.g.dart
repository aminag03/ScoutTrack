// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  birthDate: DateTime.parse(json['birthDate'] as String),
  gender: (json['gender'] as num?)?.toInt() ?? 0,
  genderName: json['genderName'] as String? ?? '',
  contactPhone: json['contactPhone'] as String? ?? '',
  profilePictureUrl: json['profilePictureUrl'] as String? ?? '',
  troopId: (json['troopId'] as num?)?.toInt() ?? 0,
  troopName: json['troopName'] as String? ?? '',
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'birthDate': instance.birthDate.toIso8601String(),
  'gender': instance.gender,
  'genderName': instance.genderName,
  'contactPhone': instance.contactPhone,
  'profilePictureUrl': instance.profilePictureUrl,
  'troopId': instance.troopId,
  'troopName': instance.troopName,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
