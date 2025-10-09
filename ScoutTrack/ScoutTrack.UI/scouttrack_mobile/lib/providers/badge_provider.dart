import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/badge.dart';
import 'package:scouttrack_mobile/models/badge_requirement.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class BadgeProvider extends BaseProvider<ScoutBadge, dynamic> {
  BadgeProvider(AuthProvider? authProvider) : super(authProvider, 'Badge');

  @override
  ScoutBadge fromJson(dynamic json) {
    return ScoutBadge.fromJson(json);
  }

  Future<List<BadgeRequirement>> getBadgeRequirements(int badgeId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}BadgeRequirement?BadgeId=$badgeId&RetrieveAll=true",
      );
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['items'] != null) {
          return (data['items'] as List)
              .map((json) => BadgeRequirement.fromJson(json))
              .toList();
        }
        return [];
      } else {
        handleHttpError(response);
        throw Exception('Failed to load badge requirements');
      }
    });
  }
}
