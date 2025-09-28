import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];
  bool _shouldRedirectToLogin = false;

  Future<Map<String, dynamic>?> fetchCurrentUser({
    bool forceRefresh = false,
  }) async {
    if (_currentUser != null && !forceRefresh) return _currentUser;
    if (_accessToken == null) return null;

    final baseUrl = const String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:5164/",
    );
    final response = await http.get(
      Uri.parse('${baseUrl}Auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) {
          return null;
        }
        _currentUser = jsonDecode(response.body);
        return _currentUser;
      } catch (e) {
        return null;
      }
    } else if (response.statusCode == 401 && await refreshToken()) {
      final retryResponse = await http.get(
        Uri.parse('${baseUrl}Auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (retryResponse.statusCode == 200) {
        try {
          if (retryResponse.body.isEmpty) {
            return null;
          }
          _currentUser = jsonDecode(retryResponse.body);
          return _currentUser;
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }

  Future<String?> getUserRoleFromToken() async {
    if (_accessToken == null) return null;
    final decoded = _accessToken != null ? _decodeJwt(_accessToken!) : null;
    return decoded?['role'] ??
        decoded?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
  }

  Future<int?> getUserIdFromToken() async {
    if (_accessToken == null) return null;
    final decoded = _accessToken != null ? _decodeJwt(_accessToken!) : null;
    final id =
        decoded?['nameid'] ??
        decoded?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return jsonDecode(payload);
  }

  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    final role = await getUserRoleFromToken();
    final id = await getUserIdFromToken();

    if (role == null || id == null) return null;

    return {'id': id, 'role': role, 'username': _username};
  }

  String? _accessToken;
  String? _refreshToken;
  String? _role;
  String? _username;

  bool get isLoggedIn => _accessToken != null;
  String? get accessToken {
    return _accessToken;
  }

  String? get username => _username;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    _role = prefs.getString('role');
    _username = prefs.getString('username');

    if (_accessToken != null) {
      try {
        await fetchCurrentUser();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> login(String usernameOrEmail, String password) async {
    final baseUrl = const String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:5164/",
    );
    final url = Uri.parse('${baseUrl}Auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      _role = data['role'];
      _username = data['username'];
      await fetchCurrentUser(forceRefresh: true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      await prefs.setString('refreshToken', _refreshToken!);
      await prefs.setString('role', _role!);
      await prefs.setString('username', _username!);

      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = 'Neuspješna prijava.';

      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('title')) {
          errorMessage = errorData['title'];
        } else if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map<String, dynamic> &&
              errors.containsKey('userError')) {
            errorMessage = errors['userError'] is List
                ? errors['userError'].first
                : errors['userError'].toString();
          }
        }
      }
    }
  }

  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return await completer.future;
    }

    if (_refreshToken == null) return false;

    _isRefreshing = true;

    try {
      final baseUrl = const String.fromEnvironment(
        "BASE_URL",
        defaultValue: "http://localhost:5164/",
      );
      final response = await http.post(
        Uri.parse('${baseUrl}Auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      bool success = false;
      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            print('Empty response body from refresh endpoint');
            success = false;
          } else {
            final data = jsonDecode(response.body);
            _accessToken = data['accessToken'];
            _refreshToken = data['refreshToken'];
            _currentUser = null;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('accessToken', _accessToken!);
            await prefs.setString('refreshToken', _refreshToken!);
            print('Token refreshed successfully');
            success = true;
            notifyListeners();
          }
        } catch (e) {
          print('JSON decode error during token refresh: $e');
          print('Response body: ${response.body}');
          _accessToken = null;
          _refreshToken = null;
          notifyListeners();
          success = false;
        }
      } else {
        _accessToken = null;
        _refreshToken = null;
        notifyListeners();
        print('Failed to refresh token: ${response.statusCode}');
        print('Response body: ${response.body}');
        success = false;
      }

      for (final completer in _refreshCompleters) {
        completer.complete(success);
      }
      _refreshCompleters.clear();

      return success;
    } catch (e) {
      _accessToken = null;
      _refreshToken = null;
      notifyListeners();

      for (final completer in _refreshCompleters) {
        completer.complete(false);
      }
      _refreshCompleters.clear();

      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
    await prefs.remove('username');

    _accessToken = null;
    _refreshToken = null;
    _role = null;
    _username = null;
    _currentUser = null;

    notifyListeners();
  }

  bool get shouldRedirectToLogin => _shouldRedirectToLogin;

  void clearRedirectFlag() {
    _shouldRedirectToLogin = false;
  }

  void triggerRedirectToLogin() {
    _shouldRedirectToLogin = true;
    notifyListeners();
  }

  Future<String?> getUserRole() async {
    if (_role != null) return _role;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future getUsername() async {
    if (_username != null) return _username;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
