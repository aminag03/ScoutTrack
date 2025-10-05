// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  filePath: json['filePath'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  adminId: (json['adminId'] as num?)?.toInt() ?? 0,
  adminFullName: json['adminFullName'] as String? ?? '',
);

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'filePath': instance.filePath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'adminId': instance.adminId,
  'adminFullName': instance.adminFullName,
};
