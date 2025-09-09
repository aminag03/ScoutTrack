import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int troopCount;
  final int memberCount;

  City({
    this.id = 0,
    this.name = '',
    this.latitude = 0,
    this.longitude = 0,
    required this.createdAt,
    this.updatedAt,
    this.troopCount = 0,
    this.memberCount = 0,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return _$CityFromJson(json);
  }
}
