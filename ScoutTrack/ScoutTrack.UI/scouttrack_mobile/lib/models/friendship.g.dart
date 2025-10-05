// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friendship _$FriendshipFromJson(Map<String, dynamic> json) => Friendship(
  id: (json['id'] as num?)?.toInt() ?? 0,
  requesterId: (json['requesterId'] as num?)?.toInt() ?? 0,
  requesterUsername: json['requesterUsername'] as String? ?? '',
  requesterFirstName: json['requesterFirstName'] as String? ?? '',
  requesterLastName: json['requesterLastName'] as String? ?? '',
  requesterProfilePictureUrl:
      json['requesterProfilePictureUrl'] as String? ?? '',
  responderId: (json['responderId'] as num?)?.toInt() ?? 0,
  responderUsername: json['responderUsername'] as String? ?? '',
  responderFirstName: json['responderFirstName'] as String? ?? '',
  responderLastName: json['responderLastName'] as String? ?? '',
  responderProfilePictureUrl:
      json['responderProfilePictureUrl'] as String? ?? '',
  requestedAt: DateTime.parse(json['requestedAt'] as String),
  respondedAt: json['respondedAt'] == null
      ? null
      : DateTime.parse(json['respondedAt'] as String),
  status: json['status'] == null
      ? ''
      : const _StatusConverter().fromJson(json['status']),
  statusName: json['statusName'] as String? ?? '',
);

Map<String, dynamic> _$FriendshipToJson(Friendship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'requesterUsername': instance.requesterUsername,
      'requesterFirstName': instance.requesterFirstName,
      'requesterLastName': instance.requesterLastName,
      'requesterProfilePictureUrl': instance.requesterProfilePictureUrl,
      'responderId': instance.responderId,
      'responderUsername': instance.responderUsername,
      'responderFirstName': instance.responderFirstName,
      'responderLastName': instance.responderLastName,
      'responderProfilePictureUrl': instance.responderProfilePictureUrl,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'status': const _StatusConverter().toJson(instance.status),
      'statusName': instance.statusName,
    };
