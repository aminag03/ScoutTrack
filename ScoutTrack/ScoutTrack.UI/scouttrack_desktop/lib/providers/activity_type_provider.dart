import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/activity_type.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class ActivityTypeProvider extends BaseProvider<ActivityType, dynamic> {
  ActivityTypeProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityType');

  @override
  ActivityType fromJson(dynamic json) {
    return ActivityType.fromJson(json);
  }
}
