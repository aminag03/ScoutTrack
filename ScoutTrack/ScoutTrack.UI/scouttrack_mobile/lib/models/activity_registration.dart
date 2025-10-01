import 'package:json_annotation/json_annotation.dart';

part 'activity_registration.g.dart';

@JsonSerializable()
class ActivityRegistration {
  final int id;
  final DateTime registeredAt;
  final int activityId;
  final int memberId;
  final int
  status; // 0: Pending, 1: Approved, 2: Rejected, 3: Cancelled, 4: Completed
  final String notes;
  final String activityTitle;
  final String memberName;

  // Additional Activity data for better display
  final String activityDescription;
  final String activityLocationName;
  final String activityTypeName;
  final String activityState;
  final DateTime? activityStartTime;
  final DateTime? activityEndTime;
  final double activityFee;
  final String activityImagePath;
  final int troopId;
  final String troopName;
  final int activityTypeId;

  const ActivityRegistration({
    required this.id,
    required this.registeredAt,
    required this.activityId,
    required this.memberId,
    required this.status,
    required this.notes,
    required this.activityTitle,
    required this.memberName,
    required this.activityDescription,
    required this.activityLocationName,
    required this.activityTypeName,
    required this.activityState,
    this.activityStartTime,
    this.activityEndTime,
    required this.activityFee,
    required this.activityImagePath,
    required this.troopId,
    required this.troopName,
    required this.activityTypeId,
  });

  factory ActivityRegistration.fromJson(Map<String, dynamic> json) =>
      _$ActivityRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityRegistrationToJson(this);

  // Helper methods for status
  String get statusText {
    switch (status) {
      case 0:
        return 'Na čekanju';
      case 1:
        return 'Odobrena';
      case 2:
        return 'Odbijena';
      case 3:
        return 'Otkazana';
      case 4:
        return 'Završena';
      default:
        return 'Nepoznato';
    }
  }

  bool get isPending => status == 0;
  bool get isApproved => status == 1;
  bool get isRejected => status == 2;
  bool get isCancelled => status == 3;
  bool get isCompleted => status == 4;

  bool get canCancel => isPending || isApproved;
  bool get canComplete => isApproved;
}
