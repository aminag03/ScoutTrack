// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
  id: (json['id'] as num?)?.toInt() ?? 0,
  likedAt: DateTime.parse(json['likedAt'] as String),
  postId: (json['postId'] as num?)?.toInt() ?? 0,
  createdById: (json['createdById'] as num?)?.toInt() ?? 0,
  createdByName: json['createdByName'] as String? ?? '',
  createdByTroopName: json['createdByTroopName'] as String?,
  createdByAvatarUrl: json['createdByAvatarUrl'] as String?,
  canUnlike: json['canUnlike'] as bool? ?? false,
);

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
  'id': instance.id,
  'likedAt': instance.likedAt.toIso8601String(),
  'postId': instance.postId,
  'createdById': instance.createdById,
  'createdByName': instance.createdByName,
  'createdByTroopName': instance.createdByTroopName,
  'createdByAvatarUrl': instance.createdByAvatarUrl,
  'canUnlike': instance.canUnlike,
};
