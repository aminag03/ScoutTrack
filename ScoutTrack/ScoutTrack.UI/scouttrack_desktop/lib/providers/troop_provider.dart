import 'dart:convert';
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
    if (authProvider == null) {
      throw Exception("AuthProvider nije inicijalizovan.");
    }

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
}