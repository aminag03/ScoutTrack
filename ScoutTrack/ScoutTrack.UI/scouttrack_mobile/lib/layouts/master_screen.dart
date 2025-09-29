import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import '../providers/troop_provider.dart';
import '../screens/login_screen.dart';
import '../screens/member_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/troop_details_screen.dart';
import '../utils/navigation_utils.dart';

class MasterScreen extends StatefulWidget {
  final String headerTitle;
  final Widget body;
  final int selectedIndex;
  final Function(int)? onNavigationTap;
  final List<Widget>? actions;
  final bool showBackButton;

  const MasterScreen({
    super.key,
    required this.headerTitle,
    required this.body,
    this.selectedIndex = 0,
    this.onNavigationTap,
    this.actions,
    this.showBackButton = false,
  });

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToScreen(int index) {
    if (widget.onNavigationTap != null) {
      widget.onNavigationTap!(index);
    } else {
      switch (index) {
        case 0:
          NavigationUtils.navigateWithFade(context, const MemberHomeScreen());
          break;
        case 1:
          NavigationUtils.navigateWithFade(context, const ProfileScreen());
          break;
        case 2:
          NavigationUtils.navigateWithFade(
            context,
            const NotificationsScreen(),
          );
          break;
      }
    }
  }

  bool _shouldShowBackButton() {
    return widget.showBackButton || !_isMainNavigationScreen();
  }

  bool _isMainNavigationScreen() {
    return widget.selectedIndex >= 0 && widget.selectedIndex <= 2;
  }

  Future<void> _navigateToMyTroop(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      final troopProvider = TroopProvider(authProvider);

      final userInfo = await authProvider.getCurrentUserInfo();
      if (userInfo != null && userInfo['id'] != null) {
        final memberId = userInfo['id'] as int;

        final member = await memberProvider.getById(memberId);

        if (member.troopId > 0) {
          final troop = await troopProvider.getById(member.troopId);

          if (context.mounted) {
            Navigator.of(context).pop();
          }

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TroopDetailsScreen(troop: troop),
              ),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Niste povezani sa odredom.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nije moguće dohvatiti podatke o korisniku.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri učitavanju odreda: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    if (_shouldShowBackButton())
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.headerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.actions != null) ...widget.actions!,
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  isSelected: widget.selectedIndex == 0,
                  onTap: () => _navigateToScreen(0),
                ),
                _buildNavItem(
                  icon: Icons.person,
                  isSelected: widget.selectedIndex == 1,
                  onTap: () => _navigateToScreen(1),
                ),
                _buildNavItem(
                  icon: Icons.notifications,
                  isSelected: widget.selectedIndex == 2,
                  onTap: () => _navigateToScreen(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.sentiment_satisfied,
                  title: 'Moj odred',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _navigateToMyTroop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.group,
                  title: 'Prijatelji',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to friends screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Kalendar aktivnosti',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to activity calendar screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.location_on,
                  title: 'Mapa odreda',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to troop map screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.folder,
                  title: 'Izviđački dokumenti',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to scout documents screen
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: 'Odjavi se',
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                if (context.mounted) {
                  NavigationUtils.navigateWithFade(context, const LoginPage());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class MasterScreenBuilder {
  static Widget build({
    required String headerTitle,
    required Widget body,
    int selectedIndex = 0,
    Function(int)? onNavigationTap,
    bool showBackButton = false,
  }) {
    return MasterScreen(
      headerTitle: headerTitle,
      body: body,
      selectedIndex: selectedIndex,
      onNavigationTap: onNavigationTap,
      showBackButton: showBackButton,
    );
  }
}
