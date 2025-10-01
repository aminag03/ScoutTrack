import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';
import '../providers/auth_provider.dart';
import '../models/activity_type.dart';

class ActivityTypeProvider extends BaseProvider<ActivityType, dynamic> {
  ActivityTypeProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityType');

  @override
  ActivityType fromJson(dynamic json) {
    return ActivityType.fromJson(json);
  }

  Future<List<ActivityType>> getAllActivityTypes() async {
    try {
      return await handleWithRefresh(() async {
        final uri = Uri.parse(
          "${BaseProvider.baseUrl}ActivityType?RetrieveAll=true",
        );
        final headers = await createHeaders();
        final response = await http.get(uri, headers: headers);

        if (isValidResponse(response)) {
          final data = jsonDecode(response.body);
          if (data['items'] is List) {
            return (data['items'] as List)
                .map((item) => fromJson(item))
                .toList();
          }
        }
        return [];
      });
    } catch (e) {
      print('Error fetching activity types: $e');
      return [];
    }
  }
}
