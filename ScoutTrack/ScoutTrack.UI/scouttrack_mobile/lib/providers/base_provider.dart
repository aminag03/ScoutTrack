import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/models/search_result.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class _HttpError implements Exception {
  final String message;
  final http.Response response;

  _HttpError(this.message, this.response);

  @override
  String toString() => message;
}

abstract class BaseProvider<T, TInsertUpdate> with ChangeNotifier {
  @protected
  static String? baseUrl;

  @protected
  final String endpoint;

  final AuthProvider? authProvider;

  BaseProvider(this.authProvider, this.endpoint) {
    baseUrl ??= const String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:5164/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$endpoint";
    filter ??= {};
    filter['IncludeTotalCount'] = true;
    var queryString = getQueryString(filter);
    url = "$url?$queryString";

    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          final data = jsonDecode(response.body);
          return SearchResult<T>(
            totalCount: data['totalCount'],
            items: List<T>.from(data['items'].map((e) => fromJson(e))),
          );
        } catch (e) {
          print('JSON decode error in get(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
      } else {
        throw Exception("Nepoznata greška.");
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
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          final data = jsonDecode(response.body);
          return fromJson(data);
        } catch (e) {
          print('JSON decode error in getById(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
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
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          final data = jsonDecode(response.body);
          return fromJson(data);
        } catch (e) {
          print('JSON decode error in insert(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
      } else {
        throw Exception("Nepoznata greška.");
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
        try {
          if (response.body.isEmpty) {
            throw Exception("Prazan odgovor od servera.");
          }
          final data = jsonDecode(response.body);
          return fromJson(data);
        } catch (e) {
          print('JSON decode error in update(): $e');
          print('Response body: ${response.body}');
          throw Exception("Greška pri parsiranju podataka od servera.");
        }
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
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    String errorMsg = '';
    if (responseBody != null &&
        responseBody is Map &&
        responseBody['message'] != null) {
      errorMsg = responseBody['message'].toString().toLowerCase();
    } else {
      errorMsg = response.body.toLowerCase();
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Greška: Niste autorizovani. Molimo prijavite se ponovo.',
      );
    } else if (response.statusCode == 403) {
      throw Exception('Greška: Nemate dozvolu za ovu akciju.');
    } else if (response.statusCode == 400) {
      if (errorMsg.contains('referenc') ||
          errorMsg.contains('foreign key') ||
          errorMsg.contains('constraint') ||
          (errorMsg.contains('cannot delete') &&
              errorMsg.contains('using this'))) {
        throw Exception(
          'Greška: Ovaj zapis ne može biti obrisan jer je povezan s drugim podacima.',
        );
      }
      throw Exception(
        'Greška: Neispravan zahtjev. (${responseBody?['message'] ?? response.statusCode})',
      );
    } else if (responseBody != null && responseBody['errors'] != null) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      final userErrors = errors?['UserError'] as List<dynamic>?;

      if (userErrors != null && userErrors.isNotEmpty) {
        throw Exception('Greška: ${userErrors.join(', ')}');
      }

      throw Exception(
        'Greška: ${responseBody['message'] ?? response.statusCode}',
      );
    } else if (errorMsg.contains('referenc') ||
        errorMsg.contains('foreign key') ||
        errorMsg.contains('constraint')) {
      throw Exception(
        'Greška: Ovaj zapis ne može biti obrisan jer je povezan s drugim podacima.',
      );
    } else {
      throw Exception(
        'Greška: Nepoznata greška. Status kod: ${response.statusCode}',
      );
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw _HttpError("Greška: Niste autorizovani.", response);
    } else {
      String errorMsg = response.body;
      try {
        final decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;
        if (decoded != null && decoded is Map && decoded['message'] != null) {
          errorMsg = decoded['message'].toString().toLowerCase();
        } else {
          errorMsg = response.body.toLowerCase();
        }
      } catch (_) {
        errorMsg = response.body.toLowerCase();
      }

      if (errorMsg.contains('username') &&
          errorMsg.contains('already exists')) {
        throw _HttpError('Korisničko ime već postoji.', response);
      }
      if (errorMsg.contains('email') && errorMsg.contains('already exists')) {
        throw _HttpError('Email već postoji.', response);
      }
      if (errorMsg.contains('name') && errorMsg.contains('already exists')) {
        throw _HttpError('Naziv već postoji.', response);
      }
      if (errorMsg.contains('description') &&
          errorMsg.contains('already exists')) {
        throw _HttpError('Opis već postoji.', response);
      }
      if (errorMsg.contains('permission') && errorMsg.contains('activity')) {
        throw _HttpError(
          'Aktivnost je privatna. Nemate dozvolu za pristup.',
          response,
        );
      }
      if (errorMsg.contains('permission')) {
        throw _HttpError('Nemate dozvolu za ovu akciju.', response);
      }
      if (errorMsg.contains('cannot delete') &&
          errorMsg.contains('using this record')) {
        throw _HttpError(
          'Ne možete obrisati ovaj zapis jer je povezan s drugim podacima.',
          response,
        );
      }
      if (errorMsg.contains('age range')) {
        throw _HttpError(
          'Starosni raspon se preklapa sa već postojećom kategorijom. Molimo odaberite drugi raspon.',
          response,
        );
      }

      throw _HttpError('Došlo je do problema. Pokušajte ponovo.', response);
    }
  }

  Future<Map<String, String>> createHeaders() async {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};

    if (authProvider != null &&
        authProvider!.isLoggedIn &&
        authProvider!.accessToken != null) {
      headers['Authorization'] = 'Bearer ${authProvider!.accessToken}';
    } else {
      print('No access token available for request');
    }

    return headers;
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
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
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }

  bool _isBusinessError(http.Response response) {
    return response.statusCode == 400;
  }

  bool _isAuthError(String errorMessage) {
    final authErrorPatterns = [
      "Greška: Niste autorizovani",
      "Unauthorized",
      "401",
      "Prazan odgovor od servera",
    ];

    for (final pattern in authErrorPatterns) {
      if (errorMessage.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  Future<R> handleWithRefresh<R>(Future<R> Function() requestFn) async {
    try {
      return await requestFn();
    } catch (e) {
      if (e is _HttpError) {
        final httpError = e;
        final message = httpError.message;

        if (_isBusinessError(httpError.response)) {
          rethrow;
        }

        if (httpError.response.statusCode == 401) {
          return await _handleAuthError(message, requestFn);
        }

        rethrow;
      }

      final message = e.toString();

      if (_isAuthError(message)) {
        return await _handleAuthError(message, requestFn);
      }

      rethrow;
    }
  }

  Future<R> _handleAuthError<R>(
    String message,
    Future<R> Function() requestFn,
  ) async {
    if (authProvider == null || !authProvider!.isLoggedIn) {
      throw Exception(
        "Greška: Niste autorizovani. Molimo prijavite se ponovo.",
      );
    }

    try {
      final success = await authProvider!.refreshToken();
      if (success) {
        await Future.delayed(Duration(milliseconds: 100));
        try {
          return await requestFn();
        } catch (retryError) {
          if (retryError is _HttpError) {
            final retryHttpError = retryError;

            if (retryHttpError.response.statusCode == 401) {
              await authProvider!.logout();
              authProvider!.triggerRedirectToLogin();
              throw Exception(
                "Greška: Sesija je istekla. Molimo prijavite se ponovo.",
              );
            } else if (_isBusinessError(retryHttpError.response)) {
              rethrow;
            } else {
              rethrow;
            }
          } else {
            final retryMessage = retryError.toString();
            if (_isAuthError(retryMessage)) {
              await authProvider!.logout();
              authProvider!.triggerRedirectToLogin();
              throw Exception(
                "Greška: Sesija je istekla. Molimo prijavite se ponovo.",
              );
            } else {
              rethrow;
            }
          }
        }
      } else {
        await authProvider!.logout();
        authProvider!.triggerRedirectToLogin();
        throw Exception(
          "Greška: Sesija je istekla. Molimo prijavite se ponovo.",
        );
      }
    } catch (refreshError) {
      if (refreshError is _HttpError &&
          _isBusinessError(refreshError.response)) {
        rethrow;
      }

      final refreshErrorMessage = refreshError.toString();
      if (refreshErrorMessage.contains("već postoji") ||
          refreshErrorMessage.contains("nije ispravna") ||
          refreshErrorMessage.contains("ne smije biti") ||
          refreshErrorMessage.contains("mora imati") ||
          refreshErrorMessage.contains("se ne poklapaju") ||
          refreshErrorMessage.contains("Greška prilikom") ||
          refreshErrorMessage.contains("Greška: Neuspješno")) {
        rethrow;
      }

      await authProvider!.logout();
      authProvider!.triggerRedirectToLogin();
      throw Exception("Greška: Sesija je istekla. Molimo prijavite se ponovo.");
    }
  }
}
