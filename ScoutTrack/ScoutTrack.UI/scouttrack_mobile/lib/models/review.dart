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
    this.id = 0,
    this.content = '',
    required this.createdAt,
    this.updatedAt,
    this.rating = 0,
    this.activityId = 0,
    this.memberId = 0,
    this.activityTitle = '',
    this.memberName = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
