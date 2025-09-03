import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class EquipmentProvider extends BaseProvider<Equipment, dynamic> {
  EquipmentProvider(AuthProvider? authProvider)
    : super(authProvider, 'Equipment');

  @override
  Equipment fromJson(dynamic json) {
    return Equipment.fromJson(json);
  }

  Future<Equipment> makeGlobal(int id) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$id/make-global",
      );
      final headers = await createHeaders();

      final response = await http.patch(uri, headers: headers);
      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Greška prilikom promjene opreme u globalnu.");
      }
    });
  }
}
