// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRecommendation _$FriendRecommendationFromJson(
  Map<String, dynamic> json,
) => FriendRecommendation(
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  profilePictureUrl: json['profilePictureUrl'] as String,
  similarityScore: (json['similarityScore'] as num).toDouble(),
  troopId: (json['troopId'] as num).toInt(),
  troopName: json['troopName'] as String,
);

Map<String, dynamic> _$FriendRecommendationToJson(
  FriendRecommendation instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'profilePictureUrl': instance.profilePictureUrl,
  'similarityScore': instance.similarityScore,
  'troopId': instance.troopId,
  'troopName': instance.troopName,
};
