import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/admin.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class AdminProvider extends BaseProvider<Admin, dynamic> {
  AdminProvider(AuthProvider? authProvider) : super(authProvider, 'Admin');

  @override
  Admin fromJson(dynamic json) {
    return Admin.fromJson(json);
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

        if (errors != null && errors['userError'] != null && errors['userError'] is List && errors['userError'].isNotEmpty) {
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
}