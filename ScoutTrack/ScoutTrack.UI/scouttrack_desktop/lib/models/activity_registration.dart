import 'package:json_annotation/json_annotation.dart';

part 'activity_registration.g.dart';

@JsonSerializable()
class ActivityRegistration {
  final int id;
  final DateTime registeredAt;
  final int activityId;
  final int memberId;
  final int status;
  final String notes;
  final String activityTitle;
  final String memberName;

  ActivityRegistration({
    required this.id,
    required this.registeredAt,
    required this.activityId,
    required this.memberId,
    required this.status,
    required this.notes,
    required this.activityTitle,
    required this.memberName,
  });

  factory ActivityRegistration.fromJson(Map<String, dynamic> json) =>
      _$ActivityRegistrationFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityRegistrationToJson(this);
}
