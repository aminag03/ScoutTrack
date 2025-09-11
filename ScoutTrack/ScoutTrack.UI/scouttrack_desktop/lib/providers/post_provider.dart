import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/post.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

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
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/activity/$activityId",
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
        print('Server error (500) - Backend may not be fully implemented yet');
        return [];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['title'] ?? 'Greška prilikom učitavanja objava.');
      }
    });
  }

  Future<Post> createPost(
    String content,
    int activityId,
    List<String> imageUrls,
  ) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint",
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

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom kreiranja objave.',
        );
      }
    });
  }

  @Deprecated('Use LikeProvider.likePost instead')
  Future<Post> likePost(int postId) async {
    throw UnimplementedError('Use LikeProvider.likePost instead');
  }

  @Deprecated('Use LikeProvider.unlikePost instead')
  Future<Post> unlikePost(int postId) async {
    throw UnimplementedError('Use LikeProvider.unlikePost instead');
  }

  Future<String> uploadImage(File imageFile) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/upload-image",
      );

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${authProvider?.accessToken}';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['imageUrl'] ?? '';
      } else {
        final error = jsonDecode(responseBody);
        throw Exception(
          error['message'] ?? 'Greška prilikom učitavanja slike.',
        );
      }
    });
  }

  Future<Post> updatePost(
    int postId,
    String content,
    List<String> imageUrls,
  ) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$postId",
      );

      final response = await http.put(
        uri,
        headers: await createHeaders(),
        body: jsonEncode({'content': content, 'imageUrls': imageUrls}),
      );

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          return Post.fromJson(jsonDecode(response.body));
        } catch (e) {
          print('JSON decode error in updatePost(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(
            error['message'] ?? 'Greška prilikom ažuriranja objave.',
          );
        } catch (e) {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          throw Exception('Greška prilikom ažuriranja objave.');
        }
      }
    });
  }

  Future<bool> deletePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$postId",
      );

      final response = await http.delete(uri, headers: await createHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Greška prilikom brisanja objave.');
      }
    });
  }
}
