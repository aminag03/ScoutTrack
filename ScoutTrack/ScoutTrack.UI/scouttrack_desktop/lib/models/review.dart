import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int rating;
  final int activityId;
  final int memberId;
  final String activityTitle;
  final String memberName;

  Review({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.rating,
    required this.activityId,
    required this.memberId,
    required this.activityTitle,
    required this.memberName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
