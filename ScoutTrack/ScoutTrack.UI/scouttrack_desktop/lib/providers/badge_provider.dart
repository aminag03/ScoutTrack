import 'dart:io';
import 'dart:convert';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class BadgeProvider extends BaseProvider<Badge, Map<String, dynamic>> {
  BadgeProvider(AuthProvider authProvider) : super(authProvider, 'Badge');

  Badge fromJson(dynamic data) {
    return Badge.fromJson(data as Map<String, dynamic>);
  }

  @override
  Map<String, dynamic> toJson(Badge item) {
    return item.toJson();
  }

  Future<Badge> create({
    required String name,
    required String description,
    String imageUrl = '',
  }) async {
    final request = {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };

    return await insert(request);
  }

  Future<Badge> updateBadge({
    required int id,
    required String name,
    required String description,
    String imageUrl = '',
  }) async {
    final request = {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };

    return await update(id, request);
  }

  Future<String> uploadImage(File image) async {
    try {
      final headers = await createHeaders();
      headers.remove(
        'Content-Type',
      ); // Let the multipart form data set the content type

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${BaseProvider.baseUrl ?? "http://localhost:5164/"}${endpoint}/upload-image',
        ),
      );

      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['imageUrl'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
