import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';
import '../providers/auth_provider.dart';
import '../models/activity_registration.dart';
import '../models/search_result.dart';

class ActivityRegistrationProvider
    extends BaseProvider<ActivityRegistration, dynamic> {
  ActivityRegistrationProvider(AuthProvider? authProvider)
    : super(authProvider, 'ActivityRegistration');

  @override
  ActivityRegistration fromJson(dynamic data) {
    return ActivityRegistration.fromJson(data);
  }

  Future<SearchResult<ActivityRegistration>> getMemberRegistrations({
    int? memberId,
    List<int>? statuses,
    int page = 0,
    int pageSize = 10,
    bool retrieveAll = false,
  }) async {
    try {
      return await handleWithRefresh(() async {
        var url = "${BaseProvider.baseUrl}ActivityRegistration";
        final filter = <String, dynamic>{
          'Page': page,
          'PageSize': pageSize,
          'IncludeTotalCount': true,
          'RetrieveAll': retrieveAll,
        };

        if (memberId != null) {
          filter['MemberId'] = memberId;
        }

        if (statuses != null && statuses.isNotEmpty) {
          for (int i = 0; i < statuses.length; i++) {
            filter['Status[$i]'] = statuses[i];
          }
        }

        var queryString = getQueryString(filter);
        url = "$url?$queryString";

        final headers = await createHeaders();
        final response = await http.get(Uri.parse(url), headers: headers);

        if (isValidResponse(response)) {
          try {
            if (response.body.isEmpty) {
              throw Exception("Prazan odgovor od servera.");
            }
            final data = jsonDecode(response.body);
            return SearchResult<ActivityRegistration>(
              totalCount: data['totalCount'],
              items: List<ActivityRegistration>.from(
                data['items'].map((e) => fromJson(e)),
              ),
            );
          } catch (e) {
            print('JSON decode error in getMemberRegistrations(): $e');
            print('Response body: ${response.body}');
            throw Exception("Greška pri parsiranju podataka od servera.");
          }
        } else {
          throw Exception("Nepoznata greška.");
        }
      });
    } catch (e) {
      throw Exception('Error loading registrations: $e');
    }
  }

  Future<bool> cancelRegistration(int id) async {
    try {
      return await handleWithRefresh(() async {
        final headers = await createHeaders();
        final response = await http.post(
          Uri.parse("${BaseProvider.baseUrl}ActivityRegistration/$id/cancel"),
          headers: headers,
        );

        if (response.statusCode == 204) {
          return true;
        } else if (response.statusCode == 404) {
          throw Exception("Registracija nije pronađena.");
        } else {
          throw Exception("Greška pri otkazivanju registracije.");
        }
      });
    } catch (e) {
      throw Exception('Error canceling registration: $e');
    }
  }

  Future<ActivityRegistration> createRegistration({
    required int activityId,
    String notes = '',
  }) async {
    try {
      return await handleWithRefresh(() async {
        final headers = await createHeaders();
        final response = await http.post(
          Uri.parse("${BaseProvider.baseUrl}ActivityRegistration"),
          headers: headers,
          body: jsonEncode({'ActivityId': activityId, 'Notes': notes}),
        );

        if (isValidResponse(response)) {
          try {
            if (response.body.isEmpty) {
              throw Exception("Prazan odgovor od servera.");
            }
            final data = jsonDecode(response.body);
            return fromJson(data);
          } catch (e) {
            print('JSON decode error in createRegistration(): $e');
            print('Response body: ${response.body}');
            throw Exception("Greška pri parsiranju podataka od servera.");
          }
        } else {
          throw Exception("Nepoznata greška.");
        }
      });
    } catch (e) {
      throw Exception('Error creating registration: $e');
    }
  }

  Future<ActivityRegistration> updateRegistration({
    required int id,
    String notes = '',
  }) async {
    try {
      return await handleWithRefresh(() async {
        final headers = await createHeaders();
        final response = await http.put(
          Uri.parse("${BaseProvider.baseUrl}ActivityRegistration/$id"),
          headers: headers,
          body: jsonEncode({'Notes': notes}),
        );

        if (isValidResponse(response)) {
          try {
            if (response.body.isEmpty) {
              throw Exception("Prazan odgovor od servera.");
            }
            final data = jsonDecode(response.body);
            return fromJson(data);
          } catch (e) {
            print('JSON decode error in updateRegistration(): $e');
            print('Response body: ${response.body}');
            throw Exception("Greška pri parsiranju podataka od servera.");
          }
        } else {
          throw Exception("Nepoznata greška.");
        }
      });
    } catch (e) {
      throw Exception('Error updating registration: $e');
    }
  }
}
