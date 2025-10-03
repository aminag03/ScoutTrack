import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../models/search_result.dart';
import 'base_provider.dart';
import 'auth_provider.dart';

class ReviewProvider extends BaseProvider<Review, dynamic> {
  ReviewProvider(AuthProvider? authProvider) : super(authProvider, 'Review');

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json);
  }

  Future<SearchResult<Review>> getByActivity(
    int activityId, {
    Map<String, dynamic>? filter,
  }) async {
    var url = "${BaseProvider.baseUrl}Review/by-activity/$activityId";
    filter ??= {};
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return SearchResult<Review>(
          totalCount: data['totalCount'],
          items: List<Review>.from(data['items'].map((e) => fromJson(e))),
        );
      } else {
        throw Exception("Nepoznata greška.");
      }
    });
  }

  Future<Review?> getMyReviewForActivity(int activityId) async {
    try {
      final filter = <String, dynamic>{'retrieveAll': true};

      final reviews = await getByActivity(activityId, filter: filter);

      if (reviews.items != null && reviews.items!.isNotEmpty) {
        final currentUserId = await authProvider?.getUserIdFromToken();
        if (currentUserId != null) {
          return reviews.items!.firstWhere(
            (review) => review.memberId == currentUserId,
            orElse: () => throw StateError('No review found'),
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Review> createReview({
    required int activityId,
    required int rating,
    required String content,
  }) async {
    final data = {
      'activityId': activityId,
      'rating': rating,
      'content': content,
    };

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse("${BaseProvider.baseUrl}Review"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (isValidResponse(response)) {
        return fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Greška pri kreiranju recenzije.");
      }
    });
  }

  Future<Review> updateReview({
    required int id,
    required int rating,
    required String content,
  }) async {
    final data = {'id': id, 'rating': rating, 'content': content};

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.put(
        Uri.parse("${BaseProvider.baseUrl}Review/$id"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (isValidResponse(response)) {
        return fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Greška pri ažuriranju recenzije.");
      }
    });
  }

  Future<void> deleteReview(int id) async {
    await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.delete(
        Uri.parse("${BaseProvider.baseUrl}Review/$id"),
        headers: headers,
      );

      if (!isValidResponse(response)) {
        throw Exception("Greška pri brisanju recenzije.");
      }
    });
  }
}
