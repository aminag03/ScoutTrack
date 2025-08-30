import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/date_picker_utils.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_details_screen.dart';

import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class MemberDetailsScreen extends StatefulWidget {
  final Member member;
  final String role;
  final int loggedInUserId;
  final String? selectedMenu;

  const MemberDetailsScreen({
    super.key,
    required this.member,
    required this.role,
    required this.loggedInUserId,
    this.selectedMenu,
  });

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  late Member _member;
  bool _isLoading = false;
  late String _role;
  late int _loggedInUserId;
  List<City> _cities = [];
  List<Troop> _troops = [];
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  bool _isImageLoading = false;

  bool get isAdmin => _role == 'Admin';
  bool get isTroop => _role == 'Troop';
  bool get canEdit =>
      isAdmin || (isTroop && _loggedInUserId == _member.troopId);

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _role = widget.role;
    _loggedInUserId = widget.loggedInUserId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cityProvider = CityProvider(authProvider);
      final troopProvider = TroopProvider(authProvider);

      var filter = {"RetrieveAll": true};
      final cityResult = await cityProvider.get(filter: filter);
      final troopResult = await troopProvider.get(filter: filter);

      setState(() {
        _cities = cityResult.items ?? [];
        _troops = troopResult.items ?? [];
      });
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e);
    }
  }

  Future<void> _toggleActivation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_member.isActive ? 'Deaktivacija' : 'Aktivacija'),
        content: Text(
          _member.isActive
              ? 'Da li ste sigurni da želite deaktivirati ovog člana?'
              : 'Da li ste sigurni da želite aktivirati ovog člana?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      final updatedMember = await memberProvider.activate(_member.id);

      setState(() {
        _member = updatedMember;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _member.isActive
                  ? 'Član je uspješno aktiviran.'
                  : 'Član je uspješno deaktiviran.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onEdit() async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController firstNameController = TextEditingController(
      text: _member.firstName,
    );
    final TextEditingController lastNameController = TextEditingController(
      text: _member.lastName,
    );
    final TextEditingController usernameController = TextEditingController(
      text: _member.username,
    );
    final TextEditingController emailController = TextEditingController(
      text: _member.email,
    );
    final TextEditingController contactPhoneController = TextEditingController(
      text: _member.contactPhone,
    );
    final TextEditingController birthDateController = TextEditingController(
      text: _member.birthDate != null ? formatDate(_member.birthDate!) : '',
    );

    int? selectedCityId = _member.cityId;
    int? selectedTroopId = _member.troopId;
    int? selectedGender = _member.gender;
    bool isUpdated = false;

    Future<void> _selectBirthDate(
      BuildContext context,
      StateSetter setState,
    ) async {
      final DateTime? picked = await DatePickerUtils.showFlutterDatePicker(
        context: context,
        initialDate: _member.birthDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          birthDateController.text = formatDate(picked);
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Uredi člana',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Ime *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ime je obavezno.';
                                }
                                if (value.length > 50) {
                                  return 'Ime ne smije imati više od 50 znakova.';
                                }
                                final regex = RegExp(
                                  r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$",
                                );
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Ime može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Prezime *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Prezime je obavezan.';
                                }
                                if (value.length > 50) {
                                  return 'Prezime ne smije imati više od 50 znakova.';
                                }
                                final regex = RegExp(
                                  r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$",
                                );
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Prezime može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Korisničko ime *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Korisničko ime je obavezno.';
                                }
                                if (value.length > 50) {
                                  return 'Korisničko ime ne smije imati više od 50 znakova.';
                                }
                                if (!RegExp(
                                  r"^[A-Za-z0-9_.]+$",
                                ).hasMatch(value.trim())) {
                                  return 'Korisničko ime može sadržavati samo slova, brojeve, tačke, donje crte ili crtice.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'E-mail je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'E-mail ne smije imati više od 100 znakova.';
                                }
                                if (!RegExp(
                                  r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$",
                                ).hasMatch(value.trim())) {
                                  return 'Unesite ispravan e-mail.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: contactPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefon *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Telefon je obavezan.';
                                }
                                if (value.length > 20) {
                                  return 'Telefon ne smije imati više od 20 znakova.';
                                }
                                if (!RegExp(
                                  r'^(\+387|0)[6][0-7][0-9][0-9][0-9][0-9][0-9][0-9]$',
                                ).hasMatch(value)) {
                                  return 'Broj telefona mora biti validan za Bosnu i Hercegovinu.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _selectBirthDate(context, setState),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: birthDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Datum rođenja *',
                                    errorMaxLines: 3,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  validator: (value) =>
                                      DatePickerUtils.validateRequiredDate(
                                        value,
                                      ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Spol *',
                                errorMaxLines: 3,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Muški'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Ženski'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null) {
                                  return 'Spol je obavezan.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (val) {
                                setState(() {
                                  selectedGender = val;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedCityId,
                              decoration: const InputDecoration(
                                labelText: 'Grad *',
                                errorMaxLines: 3,
                              ),
                              items: _cities
                                  .map(
                                    (c) => DropdownMenuItem<int>(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  )
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Grad je obavezan.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (val) {
                                setState(() {
                                  selectedCityId = val;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            if (isAdmin) ...[
                              DropdownButtonFormField<int>(
                                value: selectedTroopId,
                                decoration: const InputDecoration(
                                  labelText: 'Odred *',
                                  errorMaxLines: 3,
                                ),
                                items: _troops
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(t.name),
                                      ),
                                    )
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Odred je obavezan.';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (val) {
                                  setState(() {
                                    selectedTroopId = val;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Otkaži'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                try {
                                  final requestBody = {
                                    "firstName": firstNameController.text
                                        .trim(),
                                    "lastName": lastNameController.text.trim(),
                                    "username": usernameController.text.trim(),
                                    "email": emailController.text.trim(),
                                    "contactPhone": contactPhoneController.text
                                        .trim(),
                                    "birthDate": parseDate(
                                      birthDateController.text,
                                    ).toIso8601String(),
                                    "gender": selectedGender,
                                    "cityId": selectedCityId,
                                    "troopId": isAdmin
                                        ? selectedTroopId
                                        : _member.troopId,
                                  };

                                  final memberProvider =
                                      Provider.of<MemberProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final updatedMember = await memberProvider
                                      .update(_member.id, requestBody);

                                  // Refresh the member data
                                  final refreshedMember = await memberProvider
                                      .getById(_member.id);

                                  isUpdated = true;

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Član "${refreshedMember.firstName} ${refreshedMember.lastName}" je ažuriran.',
                                        ),
                                      ),
                                    );
                                  }

                                  Navigator.of(context).pop();
                                } catch (e) {
                                  if (context.mounted)
                                    showErrorSnackbar(context, e);
                                }
                              }
                            },
                            child: const Text('Sačuvaj'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (isUpdated) {
      try {
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );
        final refreshedMember = await memberProvider.getById(_member.id);

        setState(() {
          _member = refreshedMember;
        });
      } catch (e) {
        if (context.mounted) showErrorSnackbar(context, e);
      }
    }

    return isUpdated;
  }

  Future<void> _showImagePickerDialog() async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Promijeni profilnu fotografiju'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImageBytes != null ||
                      _member.profilePictureUrl?.isNotEmpty == true)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : (_member.profilePictureUrl?.isNotEmpty == true
                                      ? Image.network(
                                          _member.profilePictureUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                        )
                                      : const Center(
                                          child: Icon(Icons.person, size: 50),
                                        )),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        final bytes = await pickedFile.readAsBytes();
                        final compressedBytes = await ImageUtils.compressImage(
                          bytes,
                        );
                        setState(() {
                          _selectedImageBytes = compressedBytes;
                          _selectedImageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: const Text('Odaberi fotografiju'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedImageBytes = null;
                  _selectedImageFile = null;
                  Navigator.of(context).pop(false);
                },
                child: const Text('Otkaži'),
              ),
              ElevatedButton(
                onPressed: _selectedImageBytes != null
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text('Sačuvaj'),
              ),
            ],
          );
        },
      ),
    );

    if (shouldSave == true && _selectedImageFile != null) {
      await _uploadImage(_selectedImageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      final updatedMember = await memberProvider.updateProfilePicture(
        _member.id,
        imageFile,
      );

      final refreshedMember = await memberProvider.getById(_member.id);

      setState(() {
        _member = refreshedMember;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilna fotografija je uspješno promijenjena.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e);
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  String _getTroopName(int? troopId) {
    if (troopId == null) return 'Nepoznat odred';
    try {
      return _troops
          .firstWhere(
            (t) => t.id == troopId,
            orElse: () => Troop(
              name: 'Nepoznat odred',
              createdAt: DateTime.now(),
              foundingDate: DateTime.now(),
            ),
          )
          .name;
    } catch (e) {
      return 'Nepoznat odred';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MasterScreen(
      selectedMenu: widget.selectedMenu,
      role: _role,
      title: 'Član "${_member.firstName} ${_member.lastName}"',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: screenWidth * 0.7,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade300,
                                child:
                                    _member.profilePictureUrl?.isNotEmpty ==
                                        true
                                    ? ClipOval(
                                        child: Image.network(
                                          _member.profilePictureUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.white,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                              ),
                              if (canEdit &&
                                  _member.profilePictureUrl?.isNotEmpty ==
                                      true &&
                                  !_isImageLoading)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Obriši profilnu fotografiju',
                                          ),
                                          content: const Text(
                                            'Jeste li sigurni da želite obrisati profilnu fotografiju?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('Odustani'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text(
                                                'Obriši',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          setState(() {
                                            _isImageLoading = true;
                                          });

                                          final memberProvider =
                                              Provider.of<MemberProvider>(
                                                context,
                                                listen: false,
                                              );
                                          await memberProvider
                                              .updateProfilePicture(
                                                _member.id,
                                                null,
                                              );

                                          final refreshedMember =
                                              await memberProvider.getById(
                                                _member.id,
                                              );

                                          setState(() {
                                            _member = refreshedMember;
                                          });

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Profilna fotografija je uspješno obrisana.',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted)
                                            showErrorSnackbar(context, e);
                                        } finally {
                                          setState(() {
                                            _isImageLoading = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (canEdit)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.image, size: 16),
                              label: const Text('Promijeni fotografiju'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(160, 40),
                              ),
                              onPressed: _showImagePickerDialog,
                            ),
                        ],
                      ),

                      const SizedBox(width: 40),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_member.firstName} ${_member.lastName}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _member.cityName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              UIComponents.buildInfoChip(
                                _member.gender == 0 ? 'Muški' : 'Ženski',
                                _member.gender == 0 ? Icons.male : Icons.female,
                                color: _member.gender == 0
                                    ? Colors.blue
                                    : Colors.pink,
                              ),
                              const SizedBox(width: 16),
                              UIComponents.buildInfoChip(
                                _member.isActive ? 'Aktivan' : 'Neaktivan',
                                _member.isActive
                                    ? Icons.check_circle
                                    : Icons.block,
                                color: _member.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 40),

                      if (canEdit)
                        Column(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Uredi podatke'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(180, 48),
                              ),
                              onPressed: () async {
                                await _onEdit();
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(
                                _member.isActive
                                    ? Icons.block
                                    : Icons.check_circle,
                              ),
                              label: Text(
                                _member.isActive ? 'Deaktiviraj' : 'Aktiviraj',
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(180, 48),
                                backgroundColor: _member.isActive
                                    ? Colors.red
                                    : Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _isLoading ? null : _toggleActivation,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIComponents.buildDetailSection('Lični podaci', [
                        UIComponents.buildDetailRow(
                          'Ime',
                          _member.firstName,
                          Icons.person,
                        ),
                        UIComponents.buildDetailRow(
                          'Prezime',
                          _member.lastName,
                          Icons.person,
                        ),
                        UIComponents.buildDetailRow(
                          'Korisničko ime',
                          _member.username,
                          Icons.account_circle,
                        ),
                        UIComponents.buildDetailRow(
                          'Datum rođenja',
                          formatDate(_member.birthDate),
                          Icons.calendar_today,
                        ),
                      ]),

                      const SizedBox(height: 30),

                      UIComponents.buildDetailSection('Kontakt informacije', [
                        UIComponents.buildDetailRow(
                          'E-mail',
                          _member.email,
                          Icons.email,
                        ),
                        UIComponents.buildDetailRow(
                          'Telefon',
                          _member.contactPhone,
                          Icons.phone,
                        ),
                      ]),

                      const SizedBox(height: 30),

                      UIComponents.buildDetailSection('Pripadnost', [
                        UIComponents.buildDetailRow(
                          'Grad',
                          _member.cityName,
                          Icons.location_city,
                        ),
                        _buildClickableTroopRow(),
                      ]),

                      const SizedBox(height: 30),
                      if (canEdit)
                        UIComponents.buildDetailSection('Sistem informacije', [
                          UIComponents.buildDetailRow(
                            'Kreiran',
                            formatDateTime(_member.createdAt),
                          ),
                          if (_member.updatedAt != null)
                            UIComponents.buildDetailRow(
                              'Izmijenjen',
                              formatDateTime(_member.updatedAt!),
                            ),
                          if (_member.lastLoginAt != null)
                            UIComponents.buildDetailRow(
                              'Zadnja prijava',
                              formatDateTime(_member.lastLoginAt!),
                            ),
                        ]),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UIComponents.buildBigActionButton(
                            icon: Icons.event,
                            label: 'Aktivnosti',
                            color: Colors.blue,
                            onPressed: _navigateToActivities,
                          ),
                          const SizedBox(width: 24),
                          UIComponents.buildBigActionButton(
                            icon: Icons.app_registration,
                            label: 'Registracije',
                            color: Colors.green,
                            onPressed: _navigateToRegistrations,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UIComponents.buildBigActionButton(
                            icon: Icons.emoji_events,
                            label: 'Vještarstva',
                            color: Colors.orange,
                            onPressed: _navigateToBadges,
                          ),
                          const SizedBox(width: 24),
                          UIComponents.buildBigActionButton(
                            icon: Icons.people,
                            label: 'Prijatelji',
                            color: Colors.purple,
                            onPressed: _navigateToFriends,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToActivities() {
    // TODO: Implement navigation to activities
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivnosti - funkcionalnost u razvoju')),
    );
  }

  void _navigateToRegistrations() {
    // TODO: Implement navigation to registrations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registracije - funkcionalnost u razvoju')),
    );
  }

  void _navigateToBadges() {
    // TODO: Implement navigation to badges
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Badges - funkcionalnost u razvoju')),
    );
  }

  void _navigateToFriends() {
    // TODO: Implement navigation to friends
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prijatelji - funkcionalnost u razvoju')),
    );
  }

  Widget _buildClickableTroopRow() {
    if (_member.troopId == null) {
      return UIComponents.buildDetailRow(
        'Odred',
        'Nepoznat odred',
        Icons.group,
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: _navigateToTroop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isHovered ? Colors.blue.shade50 : Colors.transparent,
                border: Border.all(
                  color: isHovered ? Colors.blue.shade200 : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group,
                    size: 20,
                    color: isHovered ? Colors.blue.shade600 : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Odred',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isHovered
                            ? Colors.blue.shade700
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getTroopName(_member.troopId),
                          style: TextStyle(
                            fontSize: 16,
                            color: isHovered
                                ? Colors.blue.shade700
                                : Colors.blue.shade600,
                            decoration: TextDecoration.underline,
                            fontWeight: isHovered
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isHovered ? 0.125 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: isHovered
                                ? Colors.blue.shade700
                                : Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToTroop() {
    if (_member.troopId == null) return;

    final troop = _troops.firstWhere(
      (t) => t.id == _member.troopId,
      orElse: () => Troop(
        id: _member.troopId!,
        name: _getTroopName(_member.troopId),
        createdAt: DateTime.now(),
        foundingDate: DateTime.now(),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TroopDetailsScreen(
          troop: troop,
          role: _role,
          loggedInUserId: _loggedInUserId,
        ),
      ),
    );
  }
}
