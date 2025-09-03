import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/notification.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/models/search_result.dart';

class NotificationProvider extends BaseProvider<Notification, dynamic> {
  NotificationProvider(AuthProvider? authProvider)
    : super(authProvider, 'Notification');

  @override
  Notification fromJson(dynamic json) {
    return Notification.fromJson(json);
  }

  Future<List<Notification>> sendNotificationsToUsers({
    required String message,
    required List<int> userIds,
    int? senderId,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/send-to-users",
      );
      final headers = await createHeaders();

      final requestBody = {
        "message": message,
        "userIds": userIds,
        if (senderId != null) "senderId": senderId,
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => fromJson(json)).toList();
      } else {
        throw Exception("Greška prilikom slanja obavještenja.");
      }
    });
  }

  Future<bool> markAsRead(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/mark-as-read",
      );
      final headers = await createHeaders();

      final response = await http.patch(uri, headers: headers);
      if (isValidResponse(response)) {
        return true;
      } else {
        throw Exception(
          "Greška prilikom označavanja obavještenja kao pročitanog.",
        );
      }
    });
  }

  Future<bool> markAllAsRead() async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/mark-all-as-read",
      );
      final headers = await createHeaders();

      final response = await http.patch(uri, headers: headers);
      if (isValidResponse(response)) {
        return true;
      } else {
        throw Exception(
          "Greška prilikom označavanja svih obavještenja kao pročitanih.",
        );
      }
    });
  }

  Future<int> getUnreadCount() async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/unread-count",
      );
      final headers = await createHeaders();

      final response = await http.get(uri, headers: headers);
      if (isValidResponse(response)) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Greška prilikom dohvaćanja broja nepročitanih obavještenja.",
        );
      }
    });
  }

  Future<bool> deleteNotification(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id",
      );
      final headers = await createHeaders();

      final response = await http.delete(uri, headers: headers);
      if (isValidResponse(response)) {
        return true;
      } else {
        throw Exception("Greška prilikom brisanja obavještenja.");
      }
    });
  }

  Future<bool> deleteAllNotifications() async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/delete-all",
      );
      final headers = await createHeaders();

      final response = await http.delete(uri, headers: headers);
      if (isValidResponse(response)) {
        return true;
      } else {
        throw Exception("Greška prilikom brisanja svih obavještenja.");
      }
    });
  }

  Future<SearchResult<Notification>> getMyNotifications({
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      var uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/my-notifications",
      );
      final headers = await createHeaders();

      if (filter != null && filter.isNotEmpty) {
        final queryParams = <String, String>{};
        filter.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: headers);
      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return SearchResult<Notification>(
          totalCount: data['totalCount'],
          items: List<Notification>.from(data['items'].map((e) => fromJson(e))),
        );
      } else {
        throw Exception("Greška prilikom dohvaćanja obavještenja.");
      }
    });
  }
}
