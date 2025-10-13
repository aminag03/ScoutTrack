import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_mobile/screens/home_screen.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';
import 'package:scouttrack_mobile/utils/navigation_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;
  Timer? _errorTimer;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _scrollController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _showTemporaryError(String message) {
    setState(() {
      _error = message;
    });

    _errorTimer?.cancel();

    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _error = null;
        });
      }
    });
  }

  void _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    _errorTimer?.cancel();

    final user = _userController.text.trim();
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        _loading = false;
      });
      _showTemporaryError('Unesite korisničko ime/email i lozinku.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(user, pass);
      if (authProvider.isLoggedIn) {
        final role = await authProvider.getUserRole();
        if (!mounted) return;
        if (role == 'Member') {
          NavigationUtils.navigateWithFade(context, const HomeScreen());
        } else {
          setState(() {
            _loading = false;
          });
          _showTemporaryError(
            'Samo članovi se mogu prijaviti putem mobilne aplikacije. Molimo koristite desktop aplikaciju.',
          );
        }
      } else {
        setState(() {
          _loading = false;
        });
        _showTemporaryError('Pogrešno korisničko ime/email ili lozinka.');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showTemporaryError('Došlo je do greške. Molimo pokušajte ponovo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Image.asset(
                  'assets/scouttrack_logo.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Korisničko ime ili email',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passController,
                        decoration: InputDecoration(
                          labelText: 'Lozinka',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        AnimatedOpacity(
                          opacity: _error != null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Prijava',
                                  style: TextStyle(
                                    fontSize: 16
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
