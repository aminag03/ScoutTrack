import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

@JsonSerializable()
class Document {
  final int id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int adminId;
  final String adminFullName;

  Document({
    this.id = 0,
    this.title = '',
    this.filePath = '',
    required this.createdAt,
    this.updatedAt,
    this.adminId = 0,
    this.adminFullName = '',
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return _$DocumentFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$DocumentToJson(this);
  }
}
