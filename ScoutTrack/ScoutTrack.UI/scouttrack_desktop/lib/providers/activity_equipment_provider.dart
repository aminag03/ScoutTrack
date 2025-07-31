import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/activity_equipment.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class ActivityEquipmentProvider extends BaseProvider<ActivityEquipment, dynamic> {
  ActivityEquipmentProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityEquipment');

  @override
  ActivityEquipment fromJson(dynamic json) {
    return ActivityEquipment.fromJson(json);
  }

  Future<List<ActivityEquipment>> getByActivityId(int activityId) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/activity/$activityId",
    );
    final headers = await createHeaders();

    final response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return (data as List).map((item) => fromJson(item)).toList();
    } else {
      throw Exception("Greška prilikom dohvatanja opreme za aktivnost.");
    }
  }

  Future<bool> removeByActivityIdAndEquipmentId(int activityId, int equipmentId) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/activity/$activityId/equipment/$equipmentId",
    );
    final headers = await createHeaders();

    final response = await http.delete(uri, headers: headers);
    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Greška prilikom brisanja opreme iz aktivnosti.");
    }
  }
} 