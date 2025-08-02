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

  Future<Activity> updateImage(int id, File? imageFile) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update-image",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    if (imageFile == null) {
      try {
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
      } catch (e) {
        throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
      }
    } else {
      try {
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
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
      } catch (e) {
        throw Exception("Greška prilikom slanja slike: ${e.toString()}");
      }
    }
  }

  Future<Activity> closeRegistrations(int id) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/close-registrations",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom zatvaranja registracija.',
        );
      }
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Activity> finish(int id) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/finish",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom završavanja aktivnosti.',
        );
      }
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Activity> deactivate(int id) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/deactivate",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom deaktivacije aktivnosti.',
        );
      }
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Activity> activate(int id) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/activate",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom aktivacije aktivnosti.',
        );
      }
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Activity> updateSummary(int id, String summary) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update-summary",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }
}
