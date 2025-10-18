import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class Member {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final int gender;
  final String genderName;
  final int? categoryId;
  final String categoryName;
  final String contactPhone;
  final String profilePictureUrl;
  final int troopId;
  final String troopName;
  final int cityId;
  final String cityName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  Member({
    this.id = 0,
    this.username = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    required this.birthDate,
    this.gender = 0,
    this.genderName = '',
    this.categoryId,
    this.categoryName = '',
    this.contactPhone = '',
    this.profilePictureUrl = '',
    this.troopId = 0,
    this.troopName = '',
    this.cityId = 0,
    this.cityName = '',
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
