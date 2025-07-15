import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

abstract class BaseProvider<T, TInsertUpdate> with ChangeNotifier {
  static String? _baseUrl;
  final AuthProvider authProvider;
  final String _endpoint;

  BaseProvider(this.authProvider, this._endpoint) {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5164/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";
    filter ??= {};
    filter['includeTotalCount'] = true;
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await _handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return SearchResult<T>(
          totalCount: data['totalCount'],
          items: List<T>.from(data['items'].map((e) => fromJson(e))),
        );
      } else {
        throw Exception("Unknown error");
      }
    });
  }

  Future<T> insert(dynamic request) async {
    return await _handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse("$_baseUrl$_endpoint"),
        headers: headers,
        body: jsonEncode(request),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Unknown error");
      }
    });
  }

  Future<T> update(int id, [dynamic request]) async {
    return await _handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.put(
        Uri.parse("$_baseUrl$_endpoint/$id"),
        headers: headers,
        body: jsonEncode(request),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Unknown error");
      }
    });
  }

  Future<void> delete(int id) async {
    await _handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.delete(
        Uri.parse("$_baseUrl$_endpoint/$id"),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }

      return null;
    });
  }

  void handleHttpError(http.Response response) {
    final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    String errorMsg = '';
    if (responseBody != null && responseBody is Map && responseBody['message'] != null) {
      errorMsg = responseBody['message'].toString().toLowerCase();
    } else {
      errorMsg = response.body.toLowerCase();
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden. You do not have permission.');
    } else if (response.statusCode == 400) {
      if (errorMsg.contains('referenc') || errorMsg.contains('foreign key') || errorMsg.contains('constraint')) {
        throw Exception('Ovaj zapis ne može biti obrisan jer je referenciran od strane drugih entiteta.');
      }
      throw Exception('Neispravan zahtjev (400): ${responseBody?['message'] ?? response.statusCode}');
    } else if (responseBody != null && responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      final userErrors = errors?['UserError'] as List<dynamic>?;

      if (userErrors != null && userErrors.isNotEmpty) {
        throw Exception(userErrors.join(', '));
      }

      throw Exception('Server error: ${responseBody['message'] ?? response.statusCode}');
    } else if (errorMsg.contains('referenc') || errorMsg.contains('foreign key') || errorMsg.contains('constraint')) {
      throw Exception('Ovaj zapis ne može biti obrisan jer je referenciran od strane drugih entiteta.');
    } else {
      throw Exception('Unknown error. Status code: ${response.statusCode}');
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      print(response.body);
      throw Exception("Something bad happened. Please try again.");
    }
  }

  Future<Map<String, String>> createHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final token = authProvider.accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  Future<R> _handleWithRefresh<R>(Future<R> Function() requestFn) async {
    try {
      return await requestFn();
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        final success = await authProvider.refreshToken();
        if (success) {
          return await requestFn(); // retry once after refresh
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
