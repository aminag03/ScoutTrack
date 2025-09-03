import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/models/member_badge.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';

class MemberBadgeProvider extends BaseProvider<MemberBadge, dynamic> {
  MemberBadgeProvider(AuthProvider? authProvider)
    : super(authProvider, 'MemberBadge');

  @override
  MemberBadge fromJson(dynamic json) {
    return MemberBadge.fromJson(json as Map<String, dynamic>);
  }

  Future<List<MemberBadge>> getMembersByBadgeStatus(
    int badgeId,
    int status,
  ) async {
    var url = "${BaseProvider.baseUrl}$endpoint/badge/$badgeId/status/$status";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return List<MemberBadge>.from(data.map((e) => fromJson(e)));
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<List<MemberBadge>> getMembersByBadgeStatusAndTroop(
    int badgeId,
    int status,
    int troopId,
  ) async {
    var url =
        "${BaseProvider.baseUrl}$endpoint/badge/$badgeId/status/$status/troop/$troopId";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return List<MemberBadge>.from(data.map((e) => fromJson(e)));
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<bool> completeMemberBadge(int memberBadgeId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$memberBadgeId/complete";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return data as bool;
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<MemberBadge> createMemberBadge(int memberId, int badgeId) async {
    var url = "${BaseProvider.baseUrl}$endpoint";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final requestBody = {
        'memberId': memberId,
        'badgeId': badgeId,
        'status': 0, // InProgress
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<void> syncProgressRecordsForBadge(int badgeId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/badge/$badgeId/sync-progress";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(Uri.parse(url), headers: headers);

      if (!isValidResponse(response)) {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<void> syncProgressRecordsForBadgeAndTroop(
    int badgeId,
    int troopId,
  ) async {
    var url =
        "${BaseProvider.baseUrl}$endpoint/badge/$badgeId/sync-progress/troop/$troopId";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(Uri.parse(url), headers: headers);

      if (!isValidResponse(response)) {
        throw Exception("Nepoznata greška.");
      }
    });
  }
}
