import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class CityProvider extends BaseProvider<City, dynamic> {
  CityProvider(AuthProvider authProvider) : super(authProvider, 'City');

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }
}
