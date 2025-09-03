import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/like.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class LikeProvider extends BaseProvider<Like, dynamic> {
  LikeProvider(AuthProvider? authProvider) : super(authProvider, 'Like');

  @override
  Like fromJson(dynamic json) {
    return Like.fromJson(json);
  }

  Future<List<Like>> getByPost(
    int postId, {
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/post/$postId",
      ).replace(queryParameters: filter);

      final response = await http.get(
        uri,
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else {
          items = [];
        }

        return items.map((item) => Like.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom učitavanja lajkova.',
        );
      }
    });
  }

  Future<Like> likePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/post/$postId",
      );

      final response = await http.post(
        uri,
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        return Like.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Greška prilikom lajkanja objave.');
      }
    });
  }

  Future<bool> unlikePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/post/$postId",
      );

      final response = await http.delete(
        uri,
        headers: await createHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom uklanjanja lajka.',
        );
      }
    });
  }
}
