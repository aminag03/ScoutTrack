import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

abstract class BaseProvider<T, TInsertUpdate> with ChangeNotifier {
  @protected
  static String? baseUrl;

  @protected
  final String endpoint;
  
  final AuthProvider? authProvider;

  BaseProvider(this.authProvider, this.endpoint) {
    baseUrl ??= const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5164/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$endpoint";
    filter ??= {};
    filter['includeTotalCount'] = true;
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await handleWithRefresh(() async {
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

  Future<T> getById(int id) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint/$id"),
        headers: headers,
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception("Greška: Neuspješno dohvaćanje podataka.");
      }
    });
  }

  Future<T> insert(dynamic request) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
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
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint/$id"),
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
    await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl$endpoint/$id"),
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
      throw Exception('Greška: Niste autorizovani. Molimo prijavite se ponovo.');
    } else if (response.statusCode == 403) {
      throw Exception('Greška: Nemate dozvolu za ovu akciju.');
    } else if (response.statusCode == 400) {
      if (errorMsg.contains('referenc') || errorMsg.contains('foreign key') || errorMsg.contains('constraint')) {
        throw Exception('Greška: Ovaj zapis ne može biti obrisan jer je povezan s drugim podacima.');
      }
      throw Exception('Greška: Neispravan zahtjev. (${responseBody?['message'] ?? response.statusCode})');
    } else if (responseBody != null && responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      final userErrors = errors?['UserError'] as List<dynamic>?;

      if (userErrors != null && userErrors.isNotEmpty) {
        throw Exception('Greška: ${userErrors.join(', ')}');
      }

      throw Exception('Greška: ${responseBody['message'] ?? response.statusCode}');
    } else if (errorMsg.contains('referenc') || errorMsg.contains('foreign key') || errorMsg.contains('constraint')) {
      throw Exception('Greška: Ovaj zapis ne može biti obrisan jer je povezan s drugim podacima.');
    } else {
      throw Exception('Greška: Nepoznata greška. Status kod: ${response.statusCode}');
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Greška: Niste autorizovani.");
    } else {
      String errorMsg = response.body;
      try {
        final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        if (decoded != null && decoded is Map && decoded['message'] != null) {
          errorMsg = decoded['message'].toString().toLowerCase();
        } else {
          errorMsg = response.body.toLowerCase();
        }
      } catch (_) {
        errorMsg = response.body.toLowerCase();
      }

      if (errorMsg.contains('username') && errorMsg.contains('already exists')) {
        throw Exception('Greška: Korisničko ime već postoji.');
      }
      if (errorMsg.contains('email') && errorMsg.contains('already exists')) {
        throw Exception('Greška: Email već postoji.');
      }
      if (errorMsg.contains('name') && errorMsg.contains('already exists')) {
        throw Exception('Greška: Naziv već postoji.');
      }

      print(response.body);
      throw Exception("Greška: Došlo je do problema. Pokušajte ponovo.");
    }
  }

  Future<Map<String, String>> createHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (authProvider?.accessToken != null) {
      headers['Authorization'] = 'Bearer ${authProvider!.accessToken}';
    } else {
      debugPrint('⚠️ AuthProvider ili accessToken je null – ne dodajem Authorization header.');
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

  Future<R> handleWithRefresh<R>(Future<R> Function() requestFn) async {
    try {
      return await requestFn();
    } catch (e) {
      final message = e.toString();
      final unauthorized = message.contains("Greška: Niste autorizovani.") || message.contains("Unauthorized");

      if (unauthorized) {
        if (authProvider == null) {
          throw Exception("Greška: Niste autorizovani i AuthProvider nije dostupan.");
        }

        final success = await authProvider!.refreshToken();
        if (success) {
          return await requestFn(); // Retry
        } else {
          throw Exception("Greška: Token nije moguće osvježiti.");
        }
      } else {
        rethrow;
      }
    }
  }
}
