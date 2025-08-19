import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/models/member_badge_progress.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';

class MemberBadgeProgressProvider
    extends BaseProvider<MemberBadgeProgress, dynamic> {
  MemberBadgeProgressProvider(AuthProvider? authProvider)
    : super(authProvider, 'MemberBadgeProgress');

  @override
  MemberBadgeProgress fromJson(dynamic json) {
    return MemberBadgeProgress.fromJson(json as Map<String, dynamic>);
  }

  Future<List<MemberBadgeProgress>> getByMemberBadgeId(
    int memberBadgeId,
  ) async {
    var url = "${BaseProvider.baseUrl}$endpoint/memberBadge/$memberBadgeId";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return List<MemberBadgeProgress>.from(data.map((e) => fromJson(e)));
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<bool> updateCompletion(
    int memberBadgeProgressId,
    bool isCompleted,
  ) async {
    var url =
        "${BaseProvider.baseUrl}$endpoint/$memberBadgeProgressId/completion";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(isCompleted),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return data as bool;
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }
}
