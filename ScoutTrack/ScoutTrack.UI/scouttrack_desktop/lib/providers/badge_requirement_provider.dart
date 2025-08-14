import 'package:flutter/material.dart';
import 'package:scouttrack_desktop/models/badge_requirement.dart';
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class BadgeRequirementProvider
    extends BaseProvider<BadgeRequirement, Map<String, dynamic>> {
  BadgeRequirementProvider(AuthProvider authProvider)
    : super(authProvider, 'BadgeRequirement');

  @override
  BadgeRequirement fromJson(dynamic json) {
    return BadgeRequirement.fromJson(json as Map<String, dynamic>);
  }

  @override
  Map<String, dynamic> toJson(BadgeRequirement item) {
    return item.toJson();
  }

  Future<BadgeRequirement> create({
    required int badgeId,
    required String description,
  }) async {
    final request = {'badgeId': badgeId, 'description': description};

    return await insert(request);
  }

  Future<BadgeRequirement> updateBadgeRequirement({
    required int id,
    required int badgeId,
    required String description,
  }) async {
    final request = {'badgeId': badgeId, 'description': description};

    return await update(id, request);
  }
}
