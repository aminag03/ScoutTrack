import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

abstract class BaseProvider<T, TInsertUpdate> with ChangeNotifier {
  static String? _baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "http://localhost:5164/");
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> clearToken() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<Map<String, String>> createHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final String? token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<T>> getAll({
    String customEndpoint = '',
    Map<String, dynamic>? filter,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      String queryString =
          filter != null ? Uri(queryParameters: filter).query : '';
      String url =
          '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await http.get(
        Uri.parse(url),
        headers: await createHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map<T>((item) => fromJson(item)).toList();
        } else if (data is Map && data['result'] is List) {
          return (data['result'] as List).map<T>((item) => fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        handleHttpError(response);
        throw Exception('Unhandled HTTP error');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<T> getById(int id, {required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: await createHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        handleHttpError(response);
        throw Exception('Unhandled HTTP error');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insert(TInsertUpdate item, {required Map<String, dynamic> Function(TInsertUpdate) toJson}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await createHeaders(),
        body: jsonEncode(toJson(item)),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(int id, TInsertUpdate item, {required Map<String, dynamic> Function(TInsertUpdate) toJson}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: await createHeaders(),
        body: jsonEncode(toJson(item)),
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: await createHeaders(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  void handleHttpError(http.Response response) {
    final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden. You do not have permission.');
    } else if (responseBody != null && responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        final userErrors = errors['UserError'] as List<dynamic>?;
        if (userErrors != null && userErrors.isNotEmpty) {
          throw Exception(userErrors.join(', '));
        }
      }
      throw Exception('Server error: ${responseBody['message'] ?? response.statusCode}');
    } else {
      throw Exception('Unknown error. Status code: ${response.statusCode}');
    }
  }

  Future<String?> getUserRole() async {
    final token = await getToken();
    if (token == null) return null;
    final decoded = JwtDecoder.decode(token);
    return decoded['role'] ?? decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
  }

  Future<int?> getUserId() async {
    final token = await getToken();
    if (token == null) return null;
    final decoded = JwtDecoder.decode(token);
    final id = decoded['nameid'] ?? decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }
}
