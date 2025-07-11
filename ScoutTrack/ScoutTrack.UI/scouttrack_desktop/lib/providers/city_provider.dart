import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class CityProvider {
  static String? _baseUrl;

  CityProvider() {
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://localhost:5164',
    );
  }

  Future<dynamic> getCities(AuthProvider authProvider) async {
    var uri = Uri.parse('$_baseUrl/City');
    var headers = createHeaders(authProvider);

    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 401) {
      final success = await authProvider.refreshToken();
      if (success) {
        headers = createHeaders(authProvider);
        response = await http.get(uri, headers: headers);
      } else {
        throw Exception('Unauthorized and refresh failed.');
      }
    }

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      final cities = items.map((e) => e['name'].toString()).toList();
      return cities;
    } else {
      throw Exception('Failed to load cities: ${response.statusCode}');
    }
  }

  Map<String, String> createHeaders(AuthProvider authProvider) {
    final accessToken = authProvider.accessToken;
    if (accessToken == null) {
      throw Exception("No access token available.");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode <= 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Something went wrong, please try again later!");
    }
  }
}
