import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/screens/login_screen.dart';
import 'package:scouttrack_desktop/ui/admin/screens/admin_home_screen.dart';
import 'package:scouttrack_desktop/ui/troop/screens/troop_home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/troop_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/member_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/activity_type_provider.dart';
import 'providers/activity_registration_provider.dart';
import 'providers/review_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/badge_requirement_provider.dart';
import 'providers/member_badge_provider.dart';
import 'providers/member_badge_progress_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProxyProvider<AuthProvider, TroopProvider>(
          create: (context) =>
              TroopProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => TroopProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (context) =>
              AdminProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => AdminProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MemberProvider>(
          create: (context) =>
              MemberProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => MemberProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EquipmentProvider>(
          create: (context) => EquipmentProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => EquipmentProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityTypeProvider>(
          create: (context) => ActivityTypeProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => ActivityTypeProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityRegistrationProvider>(
          create: (context) => ActivityRegistrationProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => ActivityRegistrationProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReviewProvider>(
          create: (context) =>
              ReviewProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => ReviewProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BadgeProvider>(
          create: (context) =>
              BadgeProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => BadgeProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BadgeRequirementProvider>(
          create: (context) => BadgeRequirementProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => BadgeRequirementProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MemberBadgeProvider>(
          create: (context) => MemberBadgeProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => MemberBadgeProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MemberBadgeProgressProvider>(
          create: (context) => MemberBadgeProgressProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, __) => MemberBadgeProgressProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScoutTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Literata',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF558B6E),
          primary: const Color(0xFF558B6E),
          secondary: const Color(0xFFDDE4DC),
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFF8E1),
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF558B6E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF558B6E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.shouldRedirectToLogin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.clearRedirectFlag();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          });
        }
        if (authProvider.isLoggedIn) {
          return FutureBuilder<String?>(
            future: authProvider.getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = snapshot.data;
              final username = authProvider.username ?? '';

              if (role == 'Admin') {
                return AdminHomePage(username: username);
              } else if (role == 'Troop') {
                return TroopHomePage(username: username);
              } else {
                return const LoginPage();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
