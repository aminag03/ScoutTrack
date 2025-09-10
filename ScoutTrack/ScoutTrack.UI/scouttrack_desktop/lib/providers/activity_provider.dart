import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class ActivityProvider extends BaseProvider<Activity, dynamic> {
  ActivityProvider(AuthProvider? authProvider)
    : super(authProvider, 'Activity');

  @override
  Activity fromJson(dynamic json) {
    return Activity.fromJson(json);
  }

  Future<Activity> updateWithNotifications(int id, dynamic request) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.put(
        Uri.parse("${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update"),
        headers: headers,
        body: jsonEncode(request),
      );

      if (isValidResponse(response)) {
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          final data = jsonDecode(response.body);
          return fromJson(data);
        } catch (e) {
          print('JSON decode error in updateWithNotifications(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<Activity> updateImage(int id, File? imageFile) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update-image",
      );

      if (imageFile == null) {
        final response = await http.post(
          uri,
          headers: await createHeaders(),
          body: jsonEncode({'imagePath': null}),
        );

        if (response.statusCode == 200) {
          return Activity.fromJson(jsonDecode(response.body));
        } else {
          final error = jsonDecode(response.body);
          throw Exception(
            error['title'] ?? 'Greška prilikom brisanja naslovne fotografije.',
          );
        }
      } else {
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer ${authProvider?.accessToken}'
          ..files.add(
            await http.MultipartFile.fromPath('Image', imageFile.path),
          );

        final response = await request.send();

        if (response.statusCode == 200) {
          final body = await response.stream.bytesToString();

          try {
            final decoded = jsonDecode(body);
            return Activity.fromJson(decoded);
          } catch (e) {
            throw Exception(body);
          }
        } else {
          final body = await response.stream.bytesToString();
          final error = jsonDecode(body);
          throw Exception(
            error['title'] ?? 'Greška prilikom učitavanja slike.',
          );
        }
      }
    });
  }

  Future<Activity> closeRegistrations(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/close-registrations",
      );

      final response = await http.put(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom zatvaranja registracija.',
        );
      }
    });
  }

  Future<Activity> finish(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/finish",
      );

      final response = await http.put(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom završavanja aktivnosti.',
        );
      }
    });
  }

  Future<Activity> deactivate(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/deactivate",
      );

      final response = await http.put(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom deaktivacije aktivnosti.',
        );
      }
    });
  }

  Future<Activity> activate(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/activate",
      );

      final response = await http.put(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom aktivacije aktivnosti.',
        );
      }
    });
  }

  Future<Activity> updateSummary(int id, String summary) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update-summary",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({'summary': summary}),
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom ažuriranja sažetka aktivnosti.',
        );
      }
    });
  }

  Future<Activity> togglePrivacy(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/toggle-privacy",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom promjene privatnosti aktivnosti.',
        );
      }
    });
  }
}
