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
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/post/$postId",
    ).replace(queryParameters: filter);

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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

        return items.map((item) => Comment.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom učitavanja komentara.',
        );
      }
    } catch (e) {
      print('Comment API Error: $e');
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Comment> createComment(String content, int postId) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<Comment> updateComment(int commentId, String content) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$commentId",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }

  Future<bool> deleteComment(int commentId) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$commentId",
    );

    final token = authProvider?.accessToken;
    if (token == null) throw Exception("Niste prijavljeni.");

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom brisanja komentara.',
        );
      }
    } catch (e) {
      throw Exception("Greška u komunikaciji sa serverom: ${e.toString()}");
    }
  }
}
