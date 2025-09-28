import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/member.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class MemberProvider extends BaseProvider<Member, dynamic> {
  MemberProvider(AuthProvider? authProvider) : super(authProvider, 'Member');

  @override
  Member fromJson(dynamic json) {
    return Member.fromJson(json);
  }

  Future<void> changePassword(int id, Map<String, String> request) async {
    await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/change-password",
      );
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

          if (errors != null &&
              errors['userError'] is List &&
              errors['userError'].isNotEmpty) {
            errorMessage = errors['userError'][0];
          } else if (error['title'] != null) {
            errorMessage = error['title'];
          }

          if (errorMessage == 'Old password is not valid.') {
            throw Exception('Stara lozinka nije ispravna.');
          } else if (errorMessage ==
              'New password cannot be same as old password.') {
            throw Exception('Nova lozinka ne smije biti ista kao stara.');
          } else if (errorMessage ==
              'New password must have at least 8 characters.') {
            throw Exception('Nova lozinka mora imati najmanje 8 karaktera.');
          } else if (errorMessage ==
              'New password and confirmation do not match.') {
            throw Exception('Nova lozinka i potvrda se ne poklapaju.');
          } else if (errorMessage.contains('Password must contain')) {
            throw Exception(
              'Lozinka mora sadržavati veliko i malo slovo, broj i specijalan znak.',
            );
          }

          throw Exception(errorMessage);
        } catch (e) {
          throw Exception(e.toString().replaceFirst('Exception: ', '').trim());
        }
      }
    });
  }

  Future<Member> updateProfilePicture(int id, File? imageFile) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/update-profile-picture",
      );

      if (imageFile == null) {
        final response = await http.post(
          uri,
          headers: await createHeaders(),
          body: jsonEncode({'profilePictureUrl': null}),
        );

        if (response.statusCode == 200) {
          return Member.fromJson(jsonDecode(response.body));
        } else {
          final error = jsonDecode(response.body);
          throw Exception(
            error['title'] ?? 'Greška prilikom brisanja profilne fotografije.',
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
          return await getById(id);
        } else {
          final body = await response.stream.bytesToString();
          try {
            final error = jsonDecode(body);
            throw Exception(
              error['title'] ?? 'Greška prilikom učitavanja slike.',
            );
          } catch (e) {
            throw Exception(
              'Greška prilikom učitavanja slike: ${response.statusCode}',
            );
          }
        }
      }
    });
  }

  Future<void> delete(int id) async {
    await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id",
      );
      final response = await http.delete(uri, headers: await createHeaders());

      if (response.statusCode != 200 && response.statusCode != 204) {
        try {
          final error = jsonDecode(response.body);
          throw Exception(
            error['title'] ?? 'Greška prilikom brisanja profila.',
          );
        } catch (e) {
          throw Exception(
            'Greška prilikom brisanja profila: ${response.statusCode}',
          );
        }
      }
    });
  }
}
