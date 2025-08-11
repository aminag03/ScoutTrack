// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num?)?.toInt() ?? 0,
  content: json['content'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  postId: (json['postId'] as num?)?.toInt() ?? 0,
  createdById: (json['createdById'] as num?)?.toInt() ?? 0,
  createdByName: json['createdByName'] as String? ?? '',
  createdByTroopName: json['createdByTroopName'] as String?,
  createdByAvatarUrl: json['createdByAvatarUrl'] as String?,
  canEdit: json['canEdit'] as bool? ?? false,
  canDelete: json['canDelete'] as bool? ?? false,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'postId': instance.postId,
  'createdById': instance.createdById,
  'createdByName': instance.createdByName,
  'createdByTroopName': instance.createdByTroopName,
  'createdByAvatarUrl': instance.createdByAvatarUrl,
  'canEdit': instance.canEdit,
  'canDelete': instance.canDelete,
};
