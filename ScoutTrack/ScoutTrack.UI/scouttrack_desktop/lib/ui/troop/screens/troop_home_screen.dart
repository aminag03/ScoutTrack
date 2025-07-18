import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';

class TroopHomePage extends StatelessWidget {
  final String username;
  const TroopHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: 'Troop',
      selectedMenu: 'Početna',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dobrodošli, $username!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text('Ovdje dolazi troop dashboard sadržaj...'),
        ],
      ),
    );
  }
}