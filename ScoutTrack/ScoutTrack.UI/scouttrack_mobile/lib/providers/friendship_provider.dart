import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/friendship.dart';
import '../models/friend_recommendation.dart';
import '../models/search_result.dart';
import 'base_provider.dart';
import 'auth_provider.dart';

class FriendshipProvider extends BaseProvider<Friendship, dynamic> {
  FriendshipProvider(AuthProvider? authProvider)
    : super(authProvider, 'Friendship');

  @override
  Friendship fromJson(dynamic json) {
    return Friendship.fromJson(json);
  }

  Future<SearchResult<Friendship>> getMyFriends({
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/my-friends",
      );

      if (filter != null) {
        final queryString = getQueryString(filter);
        final uriWithQuery = Uri.parse('$uri?$queryString');
        return await _getFriendships(uriWithQuery);
      }

      return await _getFriendships(uri);
    });
  }

  Future<SearchResult<Friendship>> getPendingRequests({
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/pending-requests",
      );

      if (filter != null) {
        final queryString = getQueryString(filter);
        final uriWithQuery = Uri.parse('$uri?$queryString');
        return await _getFriendships(uriWithQuery);
      }

      return await _getFriendships(uri);
    });
  }

  Future<SearchResult<Friendship>> getSentRequests({
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/sent-requests",
      );

      if (filter != null) {
        final queryString = getQueryString(filter);
        final uriWithQuery = Uri.parse('$uri?$queryString');
        return await _getFriendships(uriWithQuery);
      }

      return await _getFriendships(uri);
    });
  }

  Future<Friendship> sendFriendRequest(int responderId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/send-request",
      );
      final headers = await createHeaders();
      final requestBody = {'responderId': responderId};

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Friendship.fromJson(data);
      } else {
        handleHttpError(response);
        throw Exception('Failed to send friend request');
      }
    });
  }

  Future<bool> acceptFriendRequest(int friendshipId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$friendshipId/accept",
      );
      final headers = await createHeaders();

      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        handleHttpError(response);
        return false;
      }
    });
  }

  Future<bool> rejectFriendRequest(int friendshipId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$friendshipId/reject",
      );
      final headers = await createHeaders();

      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        handleHttpError(response);
        return false;
      }
    });
  }

  Future<bool> unfriend(int friendshipId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$friendshipId/unfriend",
      );
      final headers = await createHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        handleHttpError(response);
        return false;
      }
    });
  }

  Future<bool> cancelFriendRequest(int friendshipId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$friendshipId/cancel-request",
      );
      final headers = await createHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        handleHttpError(response);
        return false;
      }
    });
  }

  Future<List<FriendRecommendation>> getFriendRecommendations({
    int topN = 5,
    List<int>? candidateUserIds,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/recommendations?topN=$topN",
      );

      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FriendRecommendation.fromJson(json)).toList();
      } else {
        handleHttpError(response);
        throw Exception('Failed to load friend recommendations');
      }
    });
  }

  Future<SearchResult<Friendship>> _getFriendships(Uri uri) async {
    final headers = await createHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SearchResult<Friendship>.fromJson(
        data,
        (json) => Friendship.fromJson(json),
      );
    } else {
      handleHttpError(response);
      throw Exception('Failed to load friendships');
    }
  }
}
