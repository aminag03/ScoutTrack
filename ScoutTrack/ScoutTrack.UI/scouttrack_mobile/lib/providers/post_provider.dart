import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/post.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class PostProvider extends BaseProvider<Post, dynamic> {
  PostProvider(AuthProvider? authProvider) : super(authProvider, 'Post');

  @override
  Post fromJson(dynamic json) {
    return Post.fromJson(json);
  }

  Future<List<Post>> getByActivity(
    int activityId, {
    Map<String, dynamic>? filter,
  }) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/activity/$activityId",
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

        return items.map((item) => Post.fromJson(item)).toList();
      } else if (response.statusCode == 500) {
        return [];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['title'] ?? 'Greška prilikom učitavanja objava.');
      }
    });
  }

  Future<Post?> createPost(
    String content,
    int activityId,
    List<String> imageUrls,
  ) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint",
      );

      final response = await http.post(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({
          'content': content,
          'activityId': activityId,
          'imageUrls': imageUrls,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return null;
        }
        return Post.fromJson(jsonDecode(response.body));
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom kreiranja objave.');
        }
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom kreiranja objave.',
        );
      }
    });
  }

  Future<Post?> updatePost(
    int postId,
    String content,
    List<String> imageUrls,
  ) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/$postId",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({'content': content, 'imageUrls': imageUrls}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return null;
        }
        return Post.fromJson(jsonDecode(response.body));
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom ažuriranja objave.');
        }
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom ažuriranja objave.',
        );
      }
    });
  }

  Future<void> deletePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/$postId",
      );

      final response = await http.delete(uri, headers: await createHeaders());

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom brisanja objave.');
        }
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Greška prilikom brisanja objave.');
      }
    });
  }

  Future<String> uploadImage(File imageFile) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/upload-image",
      );

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${authProvider?.accessToken}';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response for image upload');
        }
        final data = jsonDecode(response.body);
        return data['imageUrl'] as String;
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom učitavanja slike.');
        }
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom učitavanja slike.',
        );
      }
    });
  }
}
