import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scouttrack_mobile/services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];
  bool _shouldRedirectToLogin = false;
  NotificationService? _notificationService;

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
    if (_accessToken == null) {
      return null;
    }

    final decoded = _accessToken != null ? _decodeJwt(_accessToken!) : null;
    if (decoded == null) {
      return null;
    }

    final id =
        decoded['nameid'] ??
        decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

    if (id is int) return id;
    if (id is String) {
      final parsedId = int.tryParse(id);
      return parsedId;
    }

    return null;
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    final role = await getUserRoleFromToken();
    final id = await getUserIdFromToken();

    if (role == null || id == null) {
      return null;
    }

    final userInfo = {'id': id, 'role': role, 'username': _username};
    return userInfo;
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
  NotificationService? get notificationService => _notificationService;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    _role = prefs.getString('role');
    _username = prefs.getString('username');

    if (_accessToken != null) {
      try {
        await fetchCurrentUser();
        await _initializeNotificationService();
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

      await _initializeNotificationService();

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

            if (_notificationService != null) {
              final userId = await getUserIdFromToken();
              if (userId != null) {
                await _notificationService!.updateTokenAndReconnect(
                  _accessToken!,
                  userId,
                );
                print('✅ Notification service token updated and reconnected');
              }
            }

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
    await _notificationService?.disconnect();
    _notificationService = null;

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

  Future<void> _initializeNotificationService() async {
    try {
      print('🔧 Starting notification service initialization...');
      final userId = await getUserIdFromToken();
      print('🔑 User ID from token: $userId');
      print('🔑 Access token exists: ${_accessToken != null}');

      if (userId == null || _accessToken == null) {
        print(
          '⚠️ Cannot initialize notification service: userId=$userId, token=${_accessToken != null}',
        );
        return;
      }

      final baseUrl = const String.fromEnvironment(
        "BASE_URL",
        defaultValue: "http://localhost:5164/",
      );
      print('🔧 Base URL: $baseUrl');

      _notificationService = NotificationService(
        baseUrl: baseUrl,
        accessToken: _accessToken,
      );

      _notificationService!.onNotificationReceived =
          (message, senderId, createdAt, activityId, notificationType) {
            print('📨 AuthProvider: Real-time notification received');
            print('📨 Message: $message');
            print('📨 SenderId: $senderId');
            print('📨 Type: $notificationType');
            print(
              '📨 onNotificationReceived callback is: ${onNotificationReceived != null ? "SET" : "NULL"}',
            );

            print(
              '📨 Calling onNotificationReceived callback (for screens)...',
            );
            if (onNotificationReceived != null) {
              onNotificationReceived!();
              print('✅ onNotificationReceived callback executed');
            } else {
              print(
                '⚠️ onNotificationReceived callback is null - no screen listening',
              );
            }

            print('📨 Calling notifyListeners()...');
            notifyListeners();
            print('✅ notifyListeners() executed');
          };

      _notificationService!.onConnected = () {
        print('Notification service connected');
      };

      _notificationService!.onDisconnected = () {
        print('Notification service disconnected');
      };

      _notificationService!.onError = (error) {
        print('Notification service error: $error');
      };

      print('🔧 Attempting to connect to SignalR...');
      await _notificationService!.connect(userId);
      print('✅ Notification service initialization complete');
    } catch (e, stackTrace) {
      print('❌ Error initializing notification service: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Function()? onNotificationReceived;

  bool get shouldRedirectToLogin => _shouldRedirectToLogin;

  Future<void> ensureSignalRConnection() async {
    if (_notificationService != null) {
      print('🔍 Checking SignalR connection status...');
      if (!_notificationService!.isConnected) {
        print('⚠️ SignalR not connected, attempting to reconnect...');
        try {
          print(
            '🔄 Attempting to refresh token before reconnecting SignalR...',
          );
          final tokenRefreshed = await refreshToken();
          if (tokenRefreshed) {
            print('✅ Token refreshed successfully');
            final userId = await getUserIdFromToken();
            if (userId != null && _accessToken != null) {
              await _notificationService!.updateTokenAndReconnect(
                _accessToken!,
                userId,
              );
              print('✅ SignalR reconnected successfully');
            }
          }
        } catch (e) {
          print('❌ Failed to reconnect SignalR: $e');
          if (e.toString().contains('401') ||
              e.toString().contains('Unauthorized')) {
            print(
              '🔐 Still getting auth error, reinitializing notification service...',
            );
            try {
              await _initializeNotificationService();
            } catch (initError) {
              print(
                '❌ Failed to reinitialize notification service: $initError',
              );
            }
          }
        }
      } else {
        print('✅ SignalR is connected');
      }
    } else {
      print('⚠️ Notification service not initialized');
    }
  }

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
