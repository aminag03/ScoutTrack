import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/troop.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

class TroopProvider extends BaseProvider<Troop, dynamic> {
  TroopProvider(AuthProvider? authProvider) : super(authProvider, 'Troop');

  @override
  Troop fromJson(dynamic json) {
    return Troop.fromJson(json);
  }
}