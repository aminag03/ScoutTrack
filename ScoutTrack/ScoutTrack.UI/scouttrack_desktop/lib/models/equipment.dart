import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  final int id;
  final String name;
  final String description;
  final bool isGlobal;
  final int? createdByTroopId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Equipment({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.isGlobal = true,
    this.createdByTroopId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}
