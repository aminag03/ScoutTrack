import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final int minAge;
  final int maxAge;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Category({
    this.id = 0,
    this.name = '',
    this.minAge = 0,
    this.maxAge = 0,
    this.description = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
