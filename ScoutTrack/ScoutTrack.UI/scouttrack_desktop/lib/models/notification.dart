import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int id;
  final String message;
  final DateTime createdAt;
  final int receiverId;
  final String receiverUsername;
  final bool isRead;
  final String senderUsername;
  final int? senderId;

  Notification({
    this.id = 0,
    this.message = '',
    required this.createdAt,
    this.receiverId = 0,
    this.receiverUsername = '',
    this.isRead = false,
    this.senderUsername = '',
    this.senderId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
