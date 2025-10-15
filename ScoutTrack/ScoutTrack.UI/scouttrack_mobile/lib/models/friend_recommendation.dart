import 'package:json_annotation/json_annotation.dart';

part 'friend_recommendation.g.dart';

@JsonSerializable()
class FriendRecommendation {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final double similarityScore;
  final int troopId;
  final String troopName;

  const FriendRecommendation({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.similarityScore,
    required this.troopId,
    required this.troopName,
  });

  factory FriendRecommendation.fromJson(Map<String, dynamic> json) =>
      _$FriendRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRecommendationToJson(this);

  String get fullName => '$firstName $lastName';
}
