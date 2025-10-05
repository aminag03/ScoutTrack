import 'package:json_annotation/json_annotation.dart';

part 'friendship.g.dart';

class _StatusConverter implements JsonConverter<String, dynamic> {
  const _StatusConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return '';

    if (json is int) {
      switch (json) {
        case 0:
          return 'Pending';
        case 1:
          return 'Accepted';
        default:
          return 'Unknown';
      }
    } else if (json is String) {
      return json;
    }

    return '';
  }

  @override
  dynamic toJson(String object) => object;
}

@JsonSerializable()
class Friendship {
  final int id;
  final int requesterId;
  final String requesterUsername;
  final String requesterFirstName;
  final String requesterLastName;
  final String requesterProfilePictureUrl;
  final int responderId;
  final String responderUsername;
  final String responderFirstName;
  final String responderLastName;
  final String responderProfilePictureUrl;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  @_StatusConverter()
  final String status;
  final String statusName;

  Friendship({
    this.id = 0,
    this.requesterId = 0,
    this.requesterUsername = '',
    this.requesterFirstName = '',
    this.requesterLastName = '',
    this.requesterProfilePictureUrl = '',
    this.responderId = 0,
    this.responderUsername = '',
    this.responderFirstName = '',
    this.responderLastName = '',
    this.responderProfilePictureUrl = '',
    required this.requestedAt,
    this.respondedAt,
    this.status = '',
    this.statusName = '',
  });

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipToJson(this);

  String get requesterFullName => '$requesterFirstName $requesterLastName';
  String get responderFullName => '$responderFirstName $responderLastName';
}
