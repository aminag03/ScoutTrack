import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../layouts/master_screen.dart';

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final username = authProvider.username;

        return MasterScreen(
          headerTitle:
              'Zdravo, ${username ?? 'User'}!',
          selectedIndex: 0,
          body: const Center(
            child: Text('Home Screen Content', style: TextStyle(fontSize: 18)),
          ),
        );
      },
    );
  }
}
