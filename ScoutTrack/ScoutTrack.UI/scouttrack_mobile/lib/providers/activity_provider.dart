import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';
import '../providers/auth_provider.dart';
import '../models/activity.dart';

class ActivityProvider extends BaseProvider<Activity, dynamic> {
  ActivityProvider(AuthProvider? authProvider)
    : super(authProvider, 'Activity');

  @override
  Activity fromJson(dynamic json) {
    return Activity.fromJson(json);
  }

  Future<List<Activity>> getMemberActivities(int memberId) async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}Activity/by-member/$memberId",
        );
        final headers = await createHeaders();
        final response = await http.get(uri, headers: headers);

        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => fromJson(item)).toList();
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching member activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getTroopActivities(int troopId) async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}Activity/by-troop/$troopId",
        );
        final headers = await createHeaders();
        final response = await http.get(uri, headers: headers);

        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => fromJson(item)).toList();
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching troop activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getRecommendedActivities({int topN = 10}) async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}Recommendation/me?topN=$topN",
        );
        final headers = await createHeaders();
        final response = await http.get(uri, headers: headers);

        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => fromJson(item)).toList();
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching recommended activities: $e');
      return [];
    }
  }

  Future<Activity?> getEarliestUpcomingActivity(int memberId) async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}Activity/earliest-upcoming/$memberId",
        );
        final headers = await createHeaders();
        final response = await http.get(uri, headers: headers);

        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          return fromJson(data);
        }
        return null;
      });
    } catch (e) {
      print('Error fetching earliest upcoming activity: $e');
      return null;
    }
  }
}
