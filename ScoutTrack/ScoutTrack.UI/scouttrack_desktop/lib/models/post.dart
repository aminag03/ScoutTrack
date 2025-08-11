import 'package:json_annotation/json_annotation.dart';
import 'package:scouttrack_desktop/models/comment.dart';
import 'package:scouttrack_desktop/models/like.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int activityId;
  final String activityTitle;
  final int createdById;
  final String createdByName;
  final String? createdByTroopName;
  final String? createdByAvatarUrl;
  final List<PostImage> images;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;
  final List<Like> likes;
  final List<Comment> comments;

  Post({
    this.id = 0,
    this.content = '',
    required this.createdAt,
    this.updatedAt,
    this.activityId = 0,
    this.activityTitle = '',
    this.createdById = 0,
    this.createdByName = '',
    this.createdByTroopName,
    this.createdByAvatarUrl,
    this.images = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByCurrentUser = false,
    this.likes = const [],
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostImage {
  final int id;
  final String imageUrl;
  final DateTime uploadedAt;
  final bool isCoverPhoto;

  PostImage({
    this.id = 0,
    this.imageUrl = '',
    required this.uploadedAt,
    this.isCoverPhoto = false,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) =>
      _$PostImageFromJson(json);

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}
