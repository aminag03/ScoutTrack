import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/models/activity_registration.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class ActivityRegistrationProvider
    extends BaseProvider<ActivityRegistration, dynamic> {
  ActivityRegistrationProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityRegistration');

  @override
  ActivityRegistration fromJson(dynamic json) {
    return ActivityRegistration.fromJson(json);
  }

  Future<SearchResult<ActivityRegistration>> getByActivity(
    int activityId, {
    Map<String, dynamic>? filter,
  }) async {
    var url =
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/by-activity/$activityId";
    filter ??= {};
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return SearchResult<ActivityRegistration>(
          totalCount: data['totalCount'],
          items: List<ActivityRegistration>.from(
            data['items'].map((e) => fromJson(e)),
          ),
        );
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<SearchResult<ActivityRegistration>> getByUser(
    int userId, {
    Map<String, dynamic>? filter,
  }) async {
    var url =
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/by-user/$userId";
    filter ??= {};
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return SearchResult<ActivityRegistration>(
          totalCount: data['totalCount'],
          items: List<ActivityRegistration>.from(
            data['items'].map((e) => fromJson(e)),
          ),
        );
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<ActivityRegistration> approve(int id) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/approve",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<ActivityRegistration> reject(int id) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/reject",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<ActivityRegistration> cancel(int id) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/cancel",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<ActivityRegistration> complete(int id) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/complete",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }
}
