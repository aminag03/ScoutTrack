import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/models/review.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

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
    var url =
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/by-activity/$activityId";
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

  // Use the base class methods for CRUD operations
  // The base class already provides insert, update, delete methods
}
