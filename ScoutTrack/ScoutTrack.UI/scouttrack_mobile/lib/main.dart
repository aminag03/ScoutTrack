import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_mobile/screens/login_screen.dart';
import 'package:scouttrack_mobile/screens/member_home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/member_provider.dart';
import 'providers/city_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/member_badge_provider.dart';
import 'utils/navigation_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => MemberProvider(authProvider)),
        ChangeNotifierProvider(create: (_) => BadgeProvider(authProvider)),
        ChangeNotifierProvider(
          create: (_) => MemberBadgeProvider(authProvider),
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
          primary: const Color(0xFF4F8055),
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
              NavigationUtils.fadeRoute(const LoginPage()),
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

              return const MemberHomeScreen();
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
