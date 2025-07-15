import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  Future<String?> getUserRoleFromToken() async {
    if (_accessToken == null) return null;
    final decoded = _accessToken != null ? _decodeJwt(_accessToken!) : null;
    return decoded?['role'] ?? decoded?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
  }

  Future<int?> getUserIdFromToken() async {
    if (_accessToken == null) return null;
    final decoded = _accessToken != null ? _decodeJwt(_accessToken!) : null;
    final id = decoded?['nameid'] ?? decoded?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }
  static String? _accessToken;
  String? _refreshToken;
  String? _role;
  String? _username;

  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get username => _username;

  Future<void> login(String usernameOrEmail, String password) async {
    final url = Uri.parse('http://localhost:5164/Auth/login');

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      await prefs.setString('refreshToken', _refreshToken!);
      await prefs.setString('role', _role!);
      await prefs.setString('username', _username!);

      notifyListeners();
    } else {
      throw Exception('Neuspješna prijava.');
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('http://localhost:5164/Auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      notifyListeners();
      return true;
    } else {
      _accessToken = null;
      _refreshToken = null;
      notifyListeners();
      return false;
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
