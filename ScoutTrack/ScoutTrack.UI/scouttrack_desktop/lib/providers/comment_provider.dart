import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/comment.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class CommentProvider extends BaseProvider<Comment, dynamic> {
  CommentProvider(AuthProvider? authProvider) : super(authProvider, 'Comment');

  @override
  Comment fromJson(dynamic json) {
    return Comment.fromJson(json);
  }

  Future<List<Comment>> getByPost(
    int postId, {
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/post/$postId",
      ).replace(queryParameters: filter);

      final response = await http.get(uri, headers: await createHeaders());

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

        return items.map((item) => Comment.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom učitavanja komentara.',
        );
      }
    });
  }

  Future<Comment> createComment(String content, int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint",
      );

      final response = await http.post(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({
          'content': content,
          'postId': postId,
          'createdById': 0, // This will be set by the backend
        }),
      );

      if (response.statusCode == 200) {
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom kreiranja komentara.',
        );
      }
    });
  }

  Future<Comment> updateComment(int commentId, String content) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$commentId",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({
          'content': content,
          'postId': 0, // This will be ignored by the backend
        }),
      );

      if (response.statusCode == 200) {
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom ažuriranja komentara.',
        );
      }
    });
  }

  Future<bool> deleteComment(int commentId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$commentId",
      );

      final response = await http.delete(uri, headers: await createHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom brisanja komentara.',
        );
      }
    });
  }
}
