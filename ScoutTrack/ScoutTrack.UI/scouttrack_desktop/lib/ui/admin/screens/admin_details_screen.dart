import 'package:flutter/material.dart';
import 'package:scouttrack_desktop/models/admin.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/providers/admin_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/form_validation_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';

class AdminDetailsScreen extends StatefulWidget {
  final Admin admin;

  const AdminDetailsScreen({super.key, required this.admin});

  @override
  State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  late Admin _admin;

  @override
  void initState() {
    super.initState();
    _admin = widget.admin;
  }

  Future<void> _showEditDialog() async {
    final usernameController = TextEditingController(text: _admin.username);
    final emailController = TextEditingController(text: _admin.email);
    final fullNameController = TextEditingController(text: _admin.fullName);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uredi profil'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Korisničko ime *',
                        ),
                        validator: (value) =>
                            FormValidationUtils.validateUsername(value),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email *'),
                        validator: (value) =>
                            FormValidationUtils.validateEmail(value),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Puno ime *',
                        ),
                        validator: (value) =>
                            FormValidationUtils.validateName(value, 'Puno ime'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Spremi'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final updatedRequest = {
      'username': usernameController.text,
      'email': emailController.text,
      'fullName': fullNameController.text,
    };

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final updatedAdmin = await provider.update(_admin.id, updatedRequest);

      setState(() {
        _admin = updatedAdmin;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil uspješno ažuriran.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška: $e')));
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    bool oldPasswordVisible = false;
    bool newPasswordVisible = false;
    bool confirmPasswordVisible = false;

    final formKey = GlobalKey<FormState>();
    String? generalError;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Promijeni lozinku'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  generalError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        TextFormField(
                          controller: oldPassController,
                          obscureText: !oldPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Stara lozinka',
                            suffixIcon: IconButton(
                              icon: Icon(
                                oldPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  oldPasswordVisible = !oldPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Unesite staru lozinku'
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: newPassController,
                          obscureText: !newPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Nova lozinka',
                            suffixIcon: IconButton(
                              icon: Icon(
                                newPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  newPasswordVisible = !newPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) =>
                              FormValidationUtils.validatePassword(v),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: confirmPassController,
                          obscureText: !confirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Potvrdi lozinku',
                            suffixIcon: IconButton(
                              icon: Icon(
                                confirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  confirmPasswordVisible =
                                      !confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) => v != newPassController.text
                              ? 'Lozinke se ne poklapaju'
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Odustani'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final provider = Provider.of<AdminProvider>(
                          context,
                          listen: false,
                        );
                        await provider.changePassword(_admin.id, {
                          'oldPassword': oldPassController.text,
                          'newPassword': newPassController.text,
                          'confirmNewPassword': confirmPassController.text,
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lozinka promijenjena. Preusmjeravanje...',
                              ),
                            ),
                          );

                          await Future.delayed(const Duration(seconds: 2));

                          if (!context.mounted) return;

                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await authProvider.logout();

                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (_) => false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            final message = e.toString();
                            if (message.contains(
                              'Stara lozinka nije ispravna',
                            )) {
                              generalError = 'Stara lozinka nije ispravna.';
                            } else if (message.contains(
                              'Nova lozinka ne smije biti ista kao stara.',
                            )) {
                              generalError =
                                  'Nova lozinka ne smije biti ista kao stara.';
                            } else if (message.contains(
                              'Lozinke se ne poklapaju',
                            )) {
                              generalError = 'Lozinke se ne poklapaju.';
                            } else {
                              generalError = message.replaceFirst(
                                'Greška: ',
                                '',
                              );
                            }
                          });

                          Future.delayed(const Duration(seconds: 4), () {
                            if (context.mounted) {
                              setState(() {
                                generalError = null;
                              });
                            }
                          });
                        }
                      }
                    }
                  },
                  child: const Text('Spremi'),
                ),
              ],
            );
          },
        );
      },
    );

    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Moj profil',
      role: 'Admin',
      selectedMenu: 'Moj profil',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalji administratora',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Uredi'),
                    onPressed: _showEditDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.password),
                    label: const Text('Promijeni lozinku'),
                    onPressed: _showChangePasswordDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              UIComponents.buildDetailRow(
                'Korisničko ime',
                _admin.username,
                Icons.person,
              ),
              UIComponents.buildDetailRow('E-mail', _admin.email, Icons.email),
              UIComponents.buildDetailRow(
                'Puno ime',
                _admin.fullName,
                Icons.person_outline,
              ),
              UIComponents.buildDetailRow(
                'Aktivan',
                _admin.isActive ? 'Da' : 'Ne',
                _admin.isActive ? Icons.check_circle : Icons.block,
              ),
              UIComponents.buildDetailRow(
                'Kreiran',
                formatDateTime(_admin.createdAt),
                Icons.date_range,
              ),
              UIComponents.buildDetailRow(
                'Zadnja izmjena',
                _admin.updatedAt != null
                    ? formatDateTime(_admin.updatedAt!)
                    : '-',
                Icons.edit,
              ),
              UIComponents.buildDetailRow(
                'Zadnja prijava',
                _admin.lastLoginAt != null
                    ? formatDateTime(_admin.lastLoginAt!)
                    : '-',
                Icons.login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
