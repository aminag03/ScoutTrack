import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/troop_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TroopProvider>(
          create: (context) => TroopProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => TroopProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (context) => AdminProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (_, auth, __) => AdminProvider(auth),
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
      home: const LoginPage(),
    );
  }
}