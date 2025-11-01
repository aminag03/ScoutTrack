import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/comment.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class CommentProvider extends BaseProvider<Comment, dynamic> {
  CommentProvider(AuthProvider? authProvider) : super(authProvider, 'Comment');

  @override
  Comment fromJson(dynamic json) {
    return Comment.fromJson(json);
  }

  Future<List<Comment>> getByPost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/post/$postId",
      );

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
      } else if (response.statusCode == 500) {
        return [];
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
        "${BaseProvider.baseUrl}$endpoint",
      );

      final response = await http.post(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({'content': content, 'postId': postId}),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return Comment(
            id: 0,
            content: content,
            createdAt: DateTime.now(),
            postId: postId,
            createdById: 0,
            createdByName: 'Current User',
            canEdit: true,
            canDelete: true,
          );
        }
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom kreiranja komentara.');
        }
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
        "${BaseProvider.baseUrl}$endpoint/$commentId",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return Comment(
            id: commentId,
            content: content,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            postId: 0,
            createdById: 0,
            createdByName: 'Current User',
            canEdit: true,
            canDelete: true,
          );
        }
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom ažuriranja komentara.');
        }
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom ažuriranja komentara.',
        );
      }
    });
  }

  Future<void> deleteComment(int commentId) async {
    return await delete(commentId);
  }
}
