import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  City({
    this.id = 0,
    this.name = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
  print("Deserializing City: $json");
  return _$CityFromJson(json);
}
}
