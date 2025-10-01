import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';
import '../models/activity_equipment.dart';
import '../providers/auth_provider.dart';

class ActivityEquipmentProvider
    extends BaseProvider<ActivityEquipment, dynamic> {
  ActivityEquipmentProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityEquipment');

  @override
  ActivityEquipment fromJson(dynamic data) {
    return ActivityEquipment.fromJson(data);
  }

  Future<List<ActivityEquipment>> getByActivityId(int activityId) async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}ActivityEquipment/activity/$activityId",
        );
        final headers = await createHeaders();

        final response = await http.get(uri, headers: headers);
        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => fromJson(item)).toList();
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching activity equipment: $e');
      return [];
    }
  }
}
