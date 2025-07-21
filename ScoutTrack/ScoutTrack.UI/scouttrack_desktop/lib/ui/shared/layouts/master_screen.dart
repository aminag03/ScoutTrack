import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/shared/screens/login_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/admin_home_screen.dart';
import 'package:scouttrack_desktop/ui/troop/screens/troop_home_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/city_list_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_list_screen.dart';

class MasterScreen extends StatefulWidget {
  final Widget child;
  final String? title; // not used anymore, optional to keep
  final String role;
  final String? selectedMenu;

  const MasterScreen({
    super.key,
    required this.child,
    this.title,
    required this.role,
    this.selectedMenu,
  });

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late String selectedLabel;

  @override
  void initState() {
    super.initState();
    selectedLabel = widget.selectedMenu ?? 'Početna';
  }

  void _handleTap(String label, VoidCallback? onTap) {
    setState(() {
      selectedLabel = label;
    });
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: const Color(0xFF4F8055),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text(
                    'ScoutTrack',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Common item
                _SidebarItem(
                  icon: Icons.home,
                  label: 'Početna',
                  selected: selectedLabel == 'Početna',
                  onTap: () => _handleTap('Početna', () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => widget.role == 'Admin'
                            ? AdminHomePage(username: 'Admin')
                            : TroopHomePage(username: 'Troop'),
                      ),
                    );
                  }),
                ),

                if (widget.role == 'Admin') ...[
                  _SidebarItem(
                    icon: Icons.location_city,
                    label: 'Gradovi',
                    selected: selectedLabel == 'Gradovi',
                    onTap: () => _handleTap('Gradovi', () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const CitiesPage()),
                      );
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.group,
                    label: 'Odredi',
                    selected: selectedLabel == 'Odredi',
                    onTap: () => _handleTap('Odredi', () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const TroopListScreen()),
                      );
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.group,
                    label: 'Članovi',
                    selected: selectedLabel == 'Članovi',
                    onTap: () => _handleTap('Članovi', () {
                    }),
                  )
                ],

                if (widget.role == 'Troop') ...[
                  _SidebarItem(
                    icon: Icons.event,
                    label: 'Moje aktivnosti',
                    selected: selectedLabel == 'Moje aktivnosti',
                    onTap: () => _handleTap('Moje aktivnosti', () {
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.badge,
                    label: 'Odred',
                    selected: selectedLabel == 'Odred',
                    onTap: () => _handleTap('Odred', () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const TroopListScreen()),
                      );
                    }),
                  ),
                ],

                const Spacer(),

                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Odjava',
                  selected: false,
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null || widget.title?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          if (widget.selectedMenu == null)
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                            ),
                          Text(
                            widget.title ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.white24 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: onTap,
        hoverColor: Colors.white30,
      ),
    );
  }
}
