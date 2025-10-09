// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num?)?.toInt() ?? 0,
  message: json['message'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  receiverId: (json['receiverId'] as num?)?.toInt() ?? 0,
  receiverUsername: json['receiverUsername'] as String? ?? '',
  isRead: json['isRead'] as bool? ?? false,
  senderUsername: json['senderUsername'] as String? ?? '',
  senderId: (json['senderId'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'receiverId': instance.receiverId,
      'receiverUsername': instance.receiverUsername,
      'isRead': instance.isRead,
      'senderUsername': instance.senderUsername,
      'senderId': instance.senderId,
    };

NotificationRequest _$NotificationRequestFromJson(Map<String, dynamic> json) =>
    NotificationRequest(
      message: json['message'] as String? ?? '',
      userIds:
          (json['userIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NotificationRequestToJson(
  NotificationRequest instance,
) => <String, dynamic>{
  'message': instance.message,
  'userIds': instance.userIds,
};
