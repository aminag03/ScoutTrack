import 'package:flutter/material.dart';
import '../layouts/master_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Obavještenja', // "Notifications" in Bosnian
      selectedIndex: 2, // Notifications is selected
      body: const Center(
        child: Text(
          'Notifications Screen Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
