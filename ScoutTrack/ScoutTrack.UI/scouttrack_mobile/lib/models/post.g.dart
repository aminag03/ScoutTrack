// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: (json['id'] as num?)?.toInt() ?? 0,
  content: json['content'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  activityId: (json['activityId'] as num?)?.toInt() ?? 0,
  activityTitle: json['activityTitle'] as String? ?? '',
  createdById: (json['createdById'] as num?)?.toInt() ?? 0,
  createdByName: json['createdByName'] as String? ?? '',
  createdByTroopName: json['createdByTroopName'] as String?,
  createdByAvatarUrl: json['createdByAvatarUrl'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => PostImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
  likes:
      (json['likes'] as List<dynamic>?)
          ?.map((e) => Like.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'activityId': instance.activityId,
  'activityTitle': instance.activityTitle,
  'createdById': instance.createdById,
  'createdByName': instance.createdByName,
  'createdByTroopName': instance.createdByTroopName,
  'createdByAvatarUrl': instance.createdByAvatarUrl,
  'images': instance.images,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'isLikedByCurrentUser': instance.isLikedByCurrentUser,
  'likes': instance.likes,
  'comments': instance.comments,
};

PostImage _$PostImageFromJson(Map<String, dynamic> json) => PostImage(
  id: (json['id'] as num?)?.toInt() ?? 0,
  imageUrl: json['imageUrl'] as String? ?? '',
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  isCoverPhoto: json['isCoverPhoto'] as bool? ?? false,
);

Map<String, dynamic> _$PostImageToJson(PostImage instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'isCoverPhoto': instance.isCoverPhoto,
};
