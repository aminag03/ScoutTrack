// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  rating: (json['rating'] as num).toInt(),
  activityId: (json['activityId'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  activityTitle: json['activityTitle'] as String,
  memberName: json['memberName'] as String,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'rating': instance.rating,
  'activityId': instance.activityId,
  'memberId': instance.memberId,
  'activityTitle': instance.activityTitle,
  'memberName': instance.memberName,
};
