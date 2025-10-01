import 'package:json_annotation/json_annotation.dart';

part 'activity_equipment.g.dart';

@JsonSerializable()
class ActivityEquipment {
  final int id;
  final int activityId;
  final int equipmentId;
  final String equipmentName;
  final String equipmentDescription;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ActivityEquipment({
    this.id = 0,
    required this.activityId,
    required this.equipmentId,
    this.equipmentName = '',
    this.equipmentDescription = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory ActivityEquipment.fromJson(Map<String, dynamic> json) =>
      _$ActivityEquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityEquipmentToJson(this);
}
