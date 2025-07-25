import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class TroopProvider extends BaseProvider<Troop, dynamic> {
  TroopProvider(AuthProvider? authProvider) : super(authProvider, 'Troop');

  @override
  Troop fromJson(dynamic json) {
    return Troop.fromJson(json);
  }

  Future<Troop> activate(int id) async {
    final uri = Uri.parse("${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/de-activate");
    final headers = await createHeaders();

    final response = await http.patch(uri, headers: headers);
    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom (de)aktivacije odreda.");
    }
  }

  Future<void> changePassword(int id, Map<String, String> request) async {
    final uri = Uri.parse("${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/change-password");
    final headers = await createHeaders();

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        final errors = error['errors'];
        String errorMessage = 'Greška pri promjeni lozinke';

        if (errors != null && errors['userError'] is List && errors['userError'].isNotEmpty) {
          errorMessage = errors['userError'][0];
        } else if (error['title'] != null) {
          errorMessage = error['title'];
        }

        if (errorMessage == 'Old password is not valid.') {
          throw Exception('Stara lozinka nije ispravna.');
        } else if (errorMessage == 'New password cannot be same as old password.') {
          throw Exception('Nova lozinka ne smije biti ista kao stara.');
        } else if (errorMessage == 'New password must have at least 8 characters.') {
          throw Exception('Nova lozinka mora imati najmanje 8 karaktera.');
        } else if (errorMessage == 'New password and confirmation do not match.') {
          throw Exception('Nova lozinka i potvrda se ne poklapaju.');
        } else if (errorMessage.contains('Password must contain')) {
          throw Exception('Lozinka mora sadržavati veliko i malo slovo, broj i specijalan znak.');
        }

        throw Exception(errorMessage);
      } catch (e) {
        throw Exception(e.toString().replaceFirst('Exception: ', '').trim());
      }
    }
  }

  Future<Troop> updateLogo(int troopId, File? imageFile) async {
    final uri = Uri.parse("${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$troopId/update-logo");

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
          body: jsonEncode({'logoUrl': null}),
        );

        if (response.statusCode == 200) {
          return Troop.fromJson(jsonDecode(response.body));
        } else {
          final error = jsonDecode(response.body);
          throw Exception(error['title'] ?? 'Greška prilikom brisanja loga.');
        }
      } catch (e) {
        throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
      }
    } 
    else {
      try {
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(await http.MultipartFile.fromPath('Image', imageFile.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final body = await response.stream.bytesToString();

          try {
            final decoded = jsonDecode(body);
            return Troop.fromJson(decoded);
          } catch (e) {
            throw Exception(body);
          }
        } else {
          final body = await response.stream.bytesToString();
          final error = jsonDecode(body);
          throw Exception(error['title'] ?? 'Greška prilikom učitavanja slike.');
        }
      } catch (e) {
        throw Exception("Greška prilikom slanja slike: ${e.toString()}");
      }
    }
  }
}