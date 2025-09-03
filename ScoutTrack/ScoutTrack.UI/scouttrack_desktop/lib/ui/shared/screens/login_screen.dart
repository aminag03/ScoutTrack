import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/admin/screens/admin_home_screen.dart';
import 'package:scouttrack_desktop/ui/troop/screens/troop_home_screen.dart';

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

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final user = _userController.text.trim();
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        _error = 'Unesite korisničko ime/email i lozinku.';
        _loading = false;
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(user, pass);
      if (authProvider.isLoggedIn) {
        final role = await authProvider.getUserRole();
        final username = await authProvider.getUsername();
        if (!mounted) return;
        if (role == 'Admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AdminHomePage(username: username),
            ),
          );
        } else if (role == 'Troop') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TroopHomePage(username: username),
            ),
          );
        } else {
          setState(() => _error = 'Nepoznata uloga korisnika.');
        }
      } else {
        setState(() {
          _error = 'Pogrešno korisničko ime/email ili lozinka.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
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
                              : const Text('Prijava'),
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
