import 'package:json_annotation/json_annotation.dart';

part 'like.g.dart';

@JsonSerializable()
class Like {
  final int id;
  final DateTime likedAt;
  final int postId;
  final int createdById;
  final String createdByName;
  final String? createdByTroopName;
  final String? createdByAvatarUrl;
  final bool canUnlike;

  Like({
    this.id = 0,
    required this.likedAt,
    this.postId = 0,
    this.createdById = 0,
    this.createdByName = '',
    this.createdByTroopName,
    this.createdByAvatarUrl,
    this.canUnlike = false,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToJson(this);
}

