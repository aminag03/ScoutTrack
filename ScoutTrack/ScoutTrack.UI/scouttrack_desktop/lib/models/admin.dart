import 'package:json_annotation/json_annotation.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  Admin({
    this.id = 0,
    this.username = '',
    this.email = '',
    this.fullName = '',
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return _$AdminFromJson(json);
  }
}
