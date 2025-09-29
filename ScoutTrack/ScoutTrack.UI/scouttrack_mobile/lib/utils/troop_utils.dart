import 'package:flutter/material.dart';
import '../models/troop.dart';
import '../screens/troop_details_screen.dart';
import 'navigation_utils.dart';

class TroopUtils {
  static Future<void> navigateToTroopDetails(
    BuildContext context,
    Troop troop,
  ) {
    return Navigator.of(
      context,
    ).push(NavigationUtils.slideRoute(TroopDetailsScreen(troop: troop)));
  }

  static Future<void> showTroopDetailsDialog(
    BuildContext context,
    Troop troop,
  ) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: TroopDetailsScreen(troop: troop),
        ),
      ),
    );
  }
}
