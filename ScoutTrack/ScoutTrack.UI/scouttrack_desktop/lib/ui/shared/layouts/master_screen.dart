import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/admin_provider.dart';
import 'package:scouttrack_desktop/ui/shared/screens/login_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/admin_home_screen.dart';
import 'package:scouttrack_desktop/ui/troop/screens/troop_home_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_details_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/city_list_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_list_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/admin_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_list_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/activity_type_list_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/equipment_list_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/activity_list_screen.dart';

class MasterScreen extends StatefulWidget {
  final Widget child;
  final String? title;
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

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
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
                      _fadeRoute(
                        widget.role == 'Admin'
                            ? AdminHomePage(username: 'Admin')
                            : TroopHomePage(username: 'Troop'),
                      ),
                    );
                  }),
                ),

                if (widget.role == 'Admin') ...[
                  _SidebarItem(
                    icon: Icons.groups,
                    label: 'Odredi',
                    selected: selectedLabel == 'Odredi',
                    onTap: () => _handleTap('Odredi', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const TroopListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.group,
                    label: 'Članovi',
                    selected: selectedLabel == 'Članovi',
                    onTap: () => _handleTap('Članovi', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const MemberListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.event,
                    label: 'Aktivnosti',
                    selected: selectedLabel == 'Aktivnosti',
                    onTap: () => _handleTap('Aktivnosti', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const ActivityListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.hiking,
                    label: 'Tipovi aktivnosti',
                    selected: selectedLabel == 'Tipovi aktivnosti',
                    onTap: () => _handleTap('Tipovi aktivnosti', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const ActivityTypeListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.backpack,
                    label: 'Oprema',
                    selected: selectedLabel == 'Oprema',
                    onTap: () => _handleTap('Oprema', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const EquipmentListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.location_city,
                    label: 'Gradovi',
                    selected: selectedLabel == 'Gradovi',
                    onTap: () => _handleTap('Gradovi', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const CityListScreen()));
                    }),
                  ),
                ],

                if (widget.role == 'Troop') ...[
                  _SidebarItem(
                    icon: Icons.badge,
                    label: 'Odredi',
                    selected: selectedLabel == 'Odredi',
                    onTap: () => _handleTap('Odredi', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const TroopListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.group,
                    label: 'Članovi',
                    selected: selectedLabel == 'Članovi',
                    onTap: () => _handleTap('Članovi', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const MemberListScreen()));
                    }),
                  ),
                  _SidebarItem(
                    icon: Icons.event,
                    label: 'Aktivnosti',
                    selected: selectedLabel == 'Aktivnosti',
                    onTap: () => _handleTap('Aktivnosti', () {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const ActivityListScreen()));
                    }),
                  ),
                ],

                const Spacer(),

                if (widget.role == 'Admin') ...[
                  _SidebarItem(
                    icon: Icons.account_circle,
                    label: 'Moj profil',
                    selected: selectedLabel == 'Moj profil',
                    onTap: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final userInfo = await authProvider.getCurrentUserInfo();

                      if (userInfo != null && userInfo['id'] != null) {
                        final adminId = userInfo['id'] as int;

                        final adminProvider = Provider.of<AdminProvider>(
                          context,
                          listen: false,
                        );
                        final admin = await adminProvider.getById(adminId);

                        _handleTap('Moj profil', () {
                          Navigator.of(context).pushReplacement(
                            _fadeRoute(AdminDetailsScreen(admin: admin)),
                          );
                        });
                      }
                    },
                  ),
                ] else if (widget.role == 'Troop') ...[
                  _SidebarItem(
                    icon: Icons.account_circle,
                    label: 'Moj profil',
                    selected: selectedLabel == 'Moj profil',
                    onTap: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final userInfo = await authProvider.getCurrentUserInfo();

                      if (userInfo != null && userInfo['id'] != null) {
                        final troopId = userInfo['id'] as int;

                        final troopProvider = Provider.of<TroopProvider>(
                          context,
                          listen: false,
                        );
                        final troop = await troopProvider.getById(troopId);

                        _handleTap('Moj profil', () {
                          Navigator.of(context).pushReplacement(
                            _fadeRoute(
                              TroopDetailsScreen(
                                troop: troop,
                                role: widget.role,
                                loggedInUserId: troopId,
                                selectedMenu: 'Moj profil',
                              ),
                            ),
                          );
                        });
                      }
                    },
                  ),
                ],
                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Odjava',
                  selected: false,
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacement(_fadeRoute(const LoginPage()));
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
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).pop(true);
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
