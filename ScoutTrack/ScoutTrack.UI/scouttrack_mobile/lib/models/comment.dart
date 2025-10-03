import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int postId;
  final int createdById;
  final String createdByName;
  final String? createdByTroopName;
  final String? createdByAvatarUrl;
  final bool canEdit;
  final bool canDelete;

  Comment({
    this.id = 0,
    this.content = '',
    required this.createdAt,
    this.updatedAt,
    this.postId = 0,
    this.createdById = 0,
    this.createdByName = '',
    this.createdByTroopName,
    this.createdByAvatarUrl,
    this.canEdit = false,
    this.canDelete = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

