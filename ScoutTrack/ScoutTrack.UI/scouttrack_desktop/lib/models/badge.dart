import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable()
class Badge {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Badge({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) =>
      _$BadgeFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}
