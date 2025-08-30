import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/activity_registration.dart';
import 'package:scouttrack_desktop/models/member_badge.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/providers/activity_registration_provider.dart';
import 'package:scouttrack_desktop/providers/activity_provider.dart';
import 'package:scouttrack_desktop/providers/member_badge_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/badge_provider.dart';
import 'package:scouttrack_desktop/providers/activity_type_provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/date_picker_utils.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/badge_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/activity_details_screen.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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

class _MemberDetailsScreenState extends State<MemberDetailsScreen>
    with TickerProviderStateMixin {
  late Member _member;
  bool _isLoading = false;
  late String _role;
  late int _loggedInUserId;
  List<City> _cities = [];
  List<Troop> _troops = [];
  List<ActivityRegistration> _activityRegistrations = [];
  List<MemberBadge> _memberBadges = [];
  bool _isLoadingRegistrations = false;
  bool _isLoadingBadges = false;

  int _currentRegistrationsPage = 1;
  int _registrationsPageSize = 10;
  int _totalRegistrations = 0;

  int _currentBadgesPage = 1;
  int _badgesPageSize = 10;
  int _totalBadges = 0;

  int? _selectedRegistrationStatus;
  int? _selectedBadgeStatus;

  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  bool _isImageLoading = false;
  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cityProvider = CityProvider(authProvider);
      final troopProvider = TroopProvider(authProvider);
      final activityRegistrationProvider = ActivityRegistrationProvider(
        authProvider,
      );
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      var filter = {"RetrieveAll": true};
      final cityResult = await cityProvider.get(filter: filter);
      final troopResult = await troopProvider.get(filter: filter);

      final registrationsFilter = {
        "memberId": _member.id,
        "page": 0,
        "pageSize": _registrationsPageSize,
        "includeTotalCount": true,
      };
      final registrationsResult = await activityRegistrationProvider.get(
        filter: registrationsFilter,
      );

      final badgesFilter = {
        "memberId": _member.id,
        "page": 0,
        "pageSize": _badgesPageSize,
        "includeTotalCount": true,
      };
      final badgesResult = await memberBadgeProvider.get(filter: badgesFilter);

      setState(() {
        _cities = cityResult.items ?? [];
        _troops = troopResult.items ?? [];
        _activityRegistrations = registrationsResult.items ?? [];
        _memberBadges = badgesResult.items ?? [];
        _totalRegistrations = registrationsResult.totalCount ?? 0;
        _totalBadges = badgesResult.totalCount ?? 0;
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

  Future<void> _loadRegistrationsPage(int page) async {
    try {
      setState(() {
        _isLoadingRegistrations = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityRegistrationProvider = ActivityRegistrationProvider(
        authProvider,
      );

      final registrationsFilter = <String, dynamic>{
        "memberId": _member.id,
        "page": page - 1,
        "pageSize": _registrationsPageSize,
        "includeTotalCount": true,
      };

      if (_selectedRegistrationStatus != null) {
        registrationsFilter["status"] = _selectedRegistrationStatus;
      }

      final registrationsResult = await activityRegistrationProvider.get(
        filter: registrationsFilter,
      );

      if (mounted) {
        setState(() {
          _activityRegistrations = registrationsResult.items ?? [];
          _totalRegistrations = registrationsResult.totalCount ?? 0;
          _currentRegistrationsPage = page;
          _isLoadingRegistrations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRegistrations = false;
        });
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _loadBadgesPage(int page) async {
    try {
      setState(() {
        _isLoadingBadges = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      final badgesFilter = <String, dynamic>{
        "memberId": _member.id,
        "page": page - 1,
        "pageSize": _badgesPageSize,
        "includeTotalCount": true,
      };

      if (_selectedBadgeStatus != null) {
        badgesFilter["status"] = _selectedBadgeStatus;
      }

      final badgesResult = await memberBadgeProvider.get(filter: badgesFilter);

      if (mounted) {
        setState(() {
          _memberBadges = badgesResult.items ?? [];
          _totalBadges = badgesResult.totalCount ?? 0;
          _currentBadgesPage = page;
          _isLoadingBadges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBadges = false;
        });
        showErrorSnackbar(context, e);
      }
    }
  }

  void _onRegistrationStatusFilterChanged(int? value) {
    setState(() {
      _selectedRegistrationStatus = value;
      _currentRegistrationsPage = 1;
    });
    _loadRegistrationsPage(1);
  }

  void _onBadgeStatusFilterChanged(int? value) {
    setState(() {
      _selectedBadgeStatus = value;
      _currentBadgesPage = 1;
    });
    _loadBadgesPage(1);
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
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 500,
                      maxHeight: 800,
                    ),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _tabController.length == 2
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, -1),
                                    ),
                                  ],
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: const Color(0xFF4F8055),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: const Color(0xFF4F8055),
                                  indicatorWeight: 3,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Registracije'),
                                    Tab(text: 'Vještarstva'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildRegistrationsTab(),
                                    _buildBadgesTab(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildRegistrationsTab() {
    if (_isLoadingRegistrations) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Registracije (${_totalRegistrations})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int?>(
                  value: _selectedRegistrationStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filtriraj po statusu',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Svi statusi'),
                    ),
                    DropdownMenuItem<int>(value: 0, child: Text('Na čekanju')),
                    DropdownMenuItem<int>(value: 1, child: Text('Odobreno')),
                    DropdownMenuItem<int>(value: 2, child: Text('Odbijeno')),
                    DropdownMenuItem<int>(value: 3, child: Text('Otkazano')),
                    DropdownMenuItem<int>(value: 4, child: Text('Završeno')),
                  ],
                  onChanged: _onRegistrationStatusFilterChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _activityRegistrations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nema registracija',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ovaj član se još nije prijavio ni na jednu aktivnost.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _activityRegistrations.length,
                  itemBuilder: (context, index) {
                    final registration = _activityRegistrations[index];
                    return _HoverableActivityCard(
                      registration: registration,
                      onTap: () => _navigateToActivity(registration),
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),
        PaginationControls(
          currentPage: _currentRegistrationsPage,
          totalPages: (_totalRegistrations / _registrationsPageSize).ceil(),
          totalCount: _totalRegistrations,
          onPageChanged: _loadRegistrationsPage,
        ),
      ],
    );
  }

  Widget _buildBadgesTab() {
    if (_isLoadingBadges) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vještarstva (${_totalBadges})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int?>(
                  value: _selectedBadgeStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filtriraj po statusu',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Svi statusi'),
                    ),
                    DropdownMenuItem<int>(value: 0, child: Text('U toku')),
                    DropdownMenuItem<int>(value: 1, child: Text('Završeno')),
                  ],
                  onChanged: _onBadgeStatusFilterChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _memberBadges.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nema vještarstva',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ovaj član još nije osvojio nijedno vještarstvo.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _memberBadges.length,
                  itemBuilder: (context, index) {
                    final badge = _memberBadges[index];
                    return _HoverableBadgeCard(
                      badge: badge,
                      onTap: () => _navigateToBadge(badge),
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),
        PaginationControls(
          currentPage: _currentBadgesPage,
          totalPages: (_totalBadges / _badgesPageSize).ceil(),
          totalCount: _totalBadges,
          onPageChanged: _loadBadgesPage,
        ),
      ],
    );
  }

  Color _getBadgeStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.green; // Awarded
      case 2:
        return Colors.red; // Rejected
      default:
        return Colors.grey;
    }
  }

  IconData _getBadgeStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending_actions; // Pending
      case 1:
        return Icons.verified; // Awarded
      case 2:
        return Icons.cancel; // Rejected
      default:
        return Icons.help_outline;
    }
  }

  String _getBadgeStatusText(int status) {
    switch (status) {
      case 0:
        return 'U toku';
      case 1:
        return 'Završeno';
      default:
        return 'Nepoznat status';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Na čekanju
      case 1:
        return Colors.green; // Odobreno
      case 2:
        return Colors.red; // Odbijeno
      case 3:
        return Colors.grey; // Otkazano
      case 4:
        return Colors.blue; // Završeno
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.schedule; // Na čekanju
      case 1:
        return Icons.check_circle; // Odobreno
      case 2:
        return Icons.cancel; // Odbijeno
      case 3:
        return Icons.block; // Otkazano
      case 4:
        return Icons.done_all; // Završeno
      default:
        return Icons.help;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Na čekanju';
      case 1:
        return 'Odobreno';
      case 2:
        return 'Odbijeno';
      case 3:
        return 'Otkazano';
      case 4:
        return 'Završeno';
      default:
        return 'Nepoznato';
    }
  }

  void _navigateToActivity(ActivityRegistration registration) async {
    if (context.mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Učitavanje podataka o aktivnosti...'),
              ],
            ),
          ),
        );

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        try {
          final token = authProvider.accessToken;
          if (token != null) {
            final decoded = _decodeJwt(token);
            if (decoded != null) {
              final exp = decoded['exp'];
              if (exp != null) {
                final expirationTime = DateTime.fromMillisecondsSinceEpoch(
                  exp * 1000,
                );
                final now = DateTime.now();
                if (now.isAfter(expirationTime)) {
                  await authProvider.refreshToken();
                }
              }
            }
          }
        } catch (e) {
          print('Token refresh failed: $e');
        }

        final activityProvider = ActivityProvider(authProvider);
        Activity activity = await activityProvider.getById(
          registration.activityId,
        );

        if (activity.troopName.isEmpty || activity.activityTypeName.isEmpty) {
          try {
            if (activity.troopName.isEmpty) {
              final troopProvider = TroopProvider(authProvider);
              final troop = await troopProvider.getById(activity.troopId);
              if (troop != null) {
                activity = Activity(
                  id: activity.id,
                  title: activity.title,
                  description: activity.description,
                  isPrivate: activity.isPrivate,
                  startTime: activity.startTime,
                  endTime: activity.endTime,
                  latitude: activity.latitude,
                  longitude: activity.longitude,
                  locationName: activity.locationName,
                  cityId: activity.cityId,
                  cityName: activity.cityName,
                  fee: activity.fee,
                  troopId: activity.troopId,
                  troopName: troop.name,
                  activityTypeId: activity.activityTypeId,
                  activityTypeName: activity.activityTypeName,
                  activityState: activity.activityState,
                  createdAt: activity.createdAt,
                  updatedAt: activity.updatedAt,
                  registrationCount: activity.registrationCount,
                  imagePath: activity.imagePath,
                  summary: activity.summary,
                );
              }
            }

            if (activity.activityTypeName.isEmpty) {
              final activityTypeProvider = ActivityTypeProvider(authProvider);
              final activityType = await activityTypeProvider.getById(
                activity.activityTypeId,
              );
              if (activityType != null) {
                activity = Activity(
                  id: activity.id,
                  title: activity.title,
                  description: activity.description,
                  isPrivate: activity.isPrivate,
                  startTime: activity.startTime,
                  endTime: activity.endTime,
                  latitude: activity.latitude,
                  longitude: activity.longitude,
                  locationName: activity.locationName,
                  cityId: activity.cityId,
                  cityName: activity.cityName,
                  fee: activity.fee,
                  troopId: activity.troopId,
                  troopName: activity.troopName,
                  activityTypeId: activity.activityTypeId,
                  activityTypeName: activityType.name,
                  activityState: activity.activityState,
                  createdAt: activity.createdAt,
                  updatedAt: activity.updatedAt,
                  registrationCount: activity.registrationCount,
                  imagePath: activity.imagePath,
                  summary: activity.summary,
                );
              }
            }
          } catch (e) {
            print('Error loading additional data: $e');
          }
        }

        if (context.mounted) {
          Navigator.of(context).pop();
          _navigateToActivityDetails(activity);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          showErrorSnackbar(context, e);
        }
      }
    }
  }

  void _navigateToActivityDetails(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityDetailsScreen(activity: activity),
      ),
    );
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return jsonDecode(payload);
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  void _navigateToBadge(MemberBadge badge) async {
    if (context.mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Učitavanje podataka o vještarstvu...'),
              ],
            ),
          ),
        );

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        try {
          final token = authProvider.accessToken;
          if (token != null) {
            final decoded = _decodeJwt(token);
            if (decoded != null) {
              final exp = decoded['exp'];
              if (exp != null) {
                final expirationTime = DateTime.fromMillisecondsSinceEpoch(
                  exp * 1000,
                );
                final now = DateTime.now();
                if (now.isAfter(expirationTime)) {
                  await authProvider.refreshToken();
                }
              }
            }
          }
        } catch (e) {
          print('Token refresh failed: $e');
        }

        final badgeProvider = BadgeProvider(authProvider);
        final completeBadge = await badgeProvider.getById(badge.badgeId);

        if (context.mounted) {
          Navigator.of(context).pop();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BadgeDetailsScreen(
                badge: completeBadge,
                role: _role,
                loggedInUserId: _loggedInUserId,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          showErrorSnackbar(context, e);
        }
      }
    }
  }
}

class _HoverableBadgeCard extends StatefulWidget {
  final MemberBadge badge;
  final VoidCallback onTap;

  const _HoverableBadgeCard({required this.badge, required this.onTap});

  @override
  State<_HoverableBadgeCard> createState() => _HoverableBadgeCardState();
}

class _HoverableBadgeCardState extends State<_HoverableBadgeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? Colors.amber.shade300 : Colors.grey.shade300,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovered ? 8 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getBadgeStatusColor(widget.badge.status),
              child: Icon(
                _getBadgeStatusIcon(widget.badge.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.badge.badgeName ?? 'Nepoznato vještarstvo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isHovered
                    ? Colors.amber.shade700
                    : Colors.amber.shade600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${_getBadgeStatusText(widget.badge.status)}'),
                if (widget.badge.createdAt != null)
                  Text('Kreirano: ${formatDateTime(widget.badge.createdAt)}'),
              ],
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Color _getBadgeStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // In Progress
      case 1:
        return Colors.green; // Completed
      case 2:
        return Colors.red; // Rejected
      default:
        return Colors.grey;
    }
  }

  IconData _getBadgeStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending; // In Progress
      case 1:
        return Icons.star; // Completed
      case 2:
        return Icons.cancel; // Rejected
      default:
        return Icons.help;
    }
  }

  String _getBadgeStatusText(int status) {
    switch (status) {
      case 0:
        return 'U toku';
      case 1:
        return 'Završeno';
      case 2:
        return 'Odbijeno';
      default:
        return 'Nepoznato';
    }
  }
}

class _HoverableActivityCard extends StatefulWidget {
  final ActivityRegistration registration;
  final VoidCallback onTap;

  const _HoverableActivityCard({
    required this.registration,
    required this.onTap,
  });

  @override
  State<_HoverableActivityCard> createState() => _HoverableActivityCardState();
}

class _HoverableActivityCardState extends State<_HoverableActivityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? Colors.blue.shade300 : Colors.grey.shade300,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovered ? 8 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(widget.registration.status),
              child: Icon(
                _getStatusIcon(widget.registration.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.registration.activityTitle ?? 'Nepoznata aktivnost',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.blue.shade700 : Colors.blue,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${_getStatusText(widget.registration.status)}'),
                if (widget.registration.notes.isNotEmpty)
                  Text('Napomena: ${widget.registration.notes}'),
                Text(
                  'Registrovan: ${formatDateTime(widget.registration.registeredAt)}',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.green; // Approved
      case 2:
        return Colors.red; // Rejected
      case 3:
        return Colors.grey; // Cancelled
      case 4:
        return Colors.blue; // Completed
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.schedule; // Pending
      case 1:
        return Icons.check_circle; // Approved
      case 2:
        return Icons.cancel; // Rejected
      case 3:
        return Icons.block; // Cancelled
      case 4:
        return Icons.done_all; // Completed
      default:
        return Icons.help;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Na čekanju';
      case 1:
        return 'Odobreno';
      case 2:
        return 'Odbijeno';
      case 3:
        return 'Otkazano';
      case 4:
        return 'Završeno';
      default:
        return 'Nepoznato';
    }
  }
}
