import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/member_badge.dart';
import 'package:scouttrack_mobile/models/member_badge_progress.dart';
import 'package:scouttrack_mobile/models/badge_requirement.dart';
import 'package:scouttrack_mobile/models/notification.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class MemberBadgeProvider extends BaseProvider<MemberBadge, dynamic> {
  MemberBadgeProvider(AuthProvider? authProvider)
    : super(authProvider, 'MemberBadge');

  @override
  MemberBadge fromJson(dynamic json) {
    return MemberBadge.fromJson(json);
  }

  Future<List<MemberBadge>> getMemberBadges(int memberId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint?MemberId=$memberId&RetrieveAll=true",
      );
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['items'] != null) {
          return (data['items'] as List)
              .map((json) => MemberBadge.fromJson(json))
              .toList();
        }
        return [];
      } else {
        handleHttpError(response);
        throw Exception('Failed to load member badges');
      }
    });
  }

  Future<List<MemberBadgeProgress>> getMemberBadgeProgress(
    int memberBadgeId,
  ) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}MemberBadgeProgress/memberBadge/$memberBadgeId",
      );
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((json) => MemberBadgeProgress.fromJson(json))
              .toList();
        }
        return [];
      } else {
        handleHttpError(response);
        throw Exception('Failed to load member badge progress');
      }
    });
  }

  Future<MemberBadge> startBadgeChallenge(
    int memberId,
    int badgeId,
    List<BadgeRequirement> requirements,
  ) async {
    return await handleWithRefresh(() async {
      final memberBadgeRequest = {
        'memberId': memberId,
        'badgeId': badgeId,
        'status': MemberBadgeStatus.inProgress.index,
        'completedAt': null,
      };

      final memberBadgeUri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}MemberBadge",
      );
      final headers = await createHeaders();
      final memberBadgeResponse = await http.post(
        memberBadgeUri,
        headers: headers,
        body: jsonEncode(memberBadgeRequest),
      );

      if (memberBadgeResponse.statusCode != 200) {
        handleHttpError(memberBadgeResponse);
        throw Exception('Failed to create member badge');
      }

      final memberBadgeData = jsonDecode(memberBadgeResponse.body);
      final memberBadge = MemberBadge.fromJson(memberBadgeData);


      return memberBadge;
    });
  }

  Future<void> notifyTroopAboutBadgeStart(
    int memberId,
    String memberName,
    String badgeName,
    int troopId,
  ) async {
    return await handleWithRefresh(() async {
      final notificationRequest = NotificationRequest(
        message:
            '${memberName.isNotEmpty ? memberName : 'Član'} je započeo rad na vještarstvu "$badgeName". Pratite njegov napredak i dodjeljujte mu napredak prema potrebi.',
        userIds: [troopId],
      );

      final notificationUri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}Notification/send-to-users",
      );
      final headers = await createHeaders();

      final notificationResponse = await http.post(
        notificationUri,
        headers: headers,
        body: jsonEncode(notificationRequest.toJson()),
      );

      if (notificationResponse.statusCode != 200) {
        handleHttpError(notificationResponse);
        throw Exception('Failed to send notification to troop');
      }
    });
  }

  Future<void> deleteMemberBadge(int memberBadgeId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}MemberBadge/$memberBadgeId",
      );
      final headers = await createHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        handleHttpError(response);
        throw Exception('Failed to delete member badge');
      }
    });
  }
}
