import 'package:json_annotation/json_annotation.dart';

part 'troop.g.dart';

@JsonSerializable()
class Troop {
  final int id;
  final String username;
  final String email;
  final String name;
  final int cityId;
  final String cityName;
  final double latitude;
  final double longitude;
  final String contactPhone;
  final String logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final int memberCount;
  final String scoutMaster;
  final String troopLeader;
  final DateTime foundingDate;

  Troop({
    this.id = 0,
    this.username = '',
    this.email = '',
    this.name = '',
    this.cityId = 0,
    this.cityName = '',
    this.latitude = 0,
    this.longitude = 0,
    this.contactPhone = '',
    this.logoUrl = '',
    this.isActive = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.memberCount = 0,
    this.scoutMaster = '',
    this.troopLeader = '',
    required this.foundingDate,
  });

  factory Troop.fromJson(Map<String, dynamic> json) {
    return _$TroopFromJson(json);
  }
}