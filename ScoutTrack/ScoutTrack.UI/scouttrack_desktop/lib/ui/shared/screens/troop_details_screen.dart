import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/date_picker_utils.dart';

import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_list_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/activity_list_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/login_screen.dart';

class TroopDetailsScreen extends StatefulWidget {
  final Troop troop;
  final String role;
  final int loggedInUserId;
  final String? selectedMenu;

  const TroopDetailsScreen({
    super.key,
    required this.troop,
    required this.role,
    required this.loggedInUserId,
    this.selectedMenu,
  });

  @override
  State<TroopDetailsScreen> createState() => _TroopDetailsScreenState();
}

class _TroopDetailsScreenState extends State<TroopDetailsScreen> {
  late Troop _troop;
  bool _isLoading = false;
  late MapController _mapController;
  LatLng? _selectedLocation;
  late String _role;
  late int _loggedInUserId;
  List<City> _cities = [];
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  bool _isImageLoading = false;

  bool get isAdmin => _role == 'Admin';
  bool get isTroop => _role == 'Troop';
  bool get isViewingOwnProfile => isTroop && _loggedInUserId == _troop.id;

  @override
  void initState() {
    super.initState();
    _troop = widget.troop;
    _role = widget.role;
    _loggedInUserId = widget.loggedInUserId;

    _mapController = MapController();
    if (_troop.latitude != null && _troop.longitude != null) {
      _selectedLocation = LatLng(_troop.latitude!, _troop.longitude!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, 13.0);
      }
      _loadCities();
    });
  }

  Future<void> _loadCities() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cityProvider = CityProvider(authProvider);
      var filter = {"RetrieveAll": true};
      final cityResult = await cityProvider.get(filter: filter);
      setState(() {
        _cities = cityResult.items ?? [];
      });
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e);
    }
  }

  Future<void> _toggleActivation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_troop.isActive ? 'Deaktivacija' : 'Aktivacija'),
        content: Text(
          _troop.isActive
              ? 'Da li ste sigurni da želite deaktivirati ovaj odred?'
              : 'Da li ste sigurni da želite aktivirati ovaj odred?',
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
      final troopProvider = Provider.of<TroopProvider>(context, listen: false);
      final updatedTroop = await troopProvider.activate(_troop.id);

      setState(() {
        _troop = updatedTroop;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _troop.isActive
                  ? 'Odred je uspješno aktiviran.'
                  : 'Odred je uspješno deaktiviran.',
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
    final TextEditingController nameController = TextEditingController(
      text: _troop.name,
    );
    final TextEditingController usernameController = TextEditingController(
      text: _troop.username,
    );
    final TextEditingController emailController = TextEditingController(
      text: _troop.email,
    );
    final TextEditingController contactPhoneController = TextEditingController(
      text: _troop.contactPhone,
    );
    final TextEditingController scoutMasterController = TextEditingController(
      text: _troop.scoutMaster,
    );
    final TextEditingController troopLeaderController = TextEditingController(
      text: _troop.troopLeader,
    );
    final TextEditingController foundingDateController = TextEditingController(
      text: _troop.foundingDate != null ? formatDate(_troop.foundingDate!) : '',
    );
    final MapController _mapController = MapController();

    LatLng selectedLocation =
        _selectedLocation ?? const LatLng(43.8563, 18.4131);
    int? selectedCityId = _troop.cityId;
    String? selectedCityName;
    bool isUpdated = false;

    if (_troop.cityId != null) {
      selectedCityName = _cities.firstWhere((c) => c.id == _troop.cityId).name;
    }

    Future<void> _selectFoundingDate(
      BuildContext context,
      StateSetter setState,
    ) async {
      final DateTime? picked = await DatePickerUtils.showDatePickerDialog(
        context: context,
        initialDate: _troop.foundingDate ?? DateTime.now(),
        minDate: DateTime(1907),
        maxDate: DateTime.now(),
        title: 'Odaberite datum osnivanja',
        controller: foundingDateController,
      );

      if (picked != null) {
        setState(() {
          foundingDateController.text = formatDate(picked);
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _openMapPicker() async {
              final result = await MapUtils.showMapPickerDialog(
                context: context,
                initialLocation: selectedLocation,
                title: 'Odaberite lokaciju',
              );

              if (result != null) {
                setState(() {
                  selectedLocation = result;
                });
              }
            }

            void _updateCityLocation(int? cityId) {
              if (cityId != null) {
                final selectedCity = _cities.firstWhere((c) => c.id == cityId);
                if (selectedCity.latitude != null &&
                    selectedCity.longitude != null) {
                  final newLocation = LatLng(
                    selectedCity.latitude!,
                    selectedCity.longitude!,
                  );
                  setState(() {
                    selectedLocation = newLocation;
                  });
                  _mapController.move(newLocation, _mapController.zoom);
                }
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 800,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Uredi odred',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Naziv *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Naziv je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'Naziv ne smije imati više od 100 znakova.';
                                }
                                final regex = RegExp(
                                  r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$",
                                );
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Naziv može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
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
                                labelText: 'Kontakt telefon *',
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
                            TextFormField(
                              controller: scoutMasterController,
                              decoration: const InputDecoration(
                                labelText: 'Starješina *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ime i prezime starješine je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'Ime i prezime starješine ne smije imati više od 100 znakova.';
                                }
                                final regex = RegExp(
                                  r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$",
                                );
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Ime i prezime starješine može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: troopLeaderController,
                              decoration: const InputDecoration(
                                labelText: 'Načelnik *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ime i prezime načelnika je obavezno';
                                }
                                if (value.length > 100) {
                                  return 'Ime i prezime načelnika ne smije biti duže od 100 znakova';
                                }

                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: foundingDateController,
                              decoration: const InputDecoration(
                                labelText: 'Datum osnivanja *',
                                errorMaxLines: 3,
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () =>
                                  _selectFoundingDate(context, setState),
                              validator: (value) =>
                                  DatePickerUtils.validateRequiredDate(value),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                  return 'Grad je obavezan';
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() {
                                  selectedCityId = val;
                                  selectedCityName = _cities
                                      .firstWhere((c) => c.id == val)
                                      .name;
                                });
                                _updateCityLocation(val);
                              },
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Lokacija odreda:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Odabrana lokacija: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 300,
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  center: selectedLocation,
                                  zoom: 10,
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      selectedLocation = point;
                                    });
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.scouttrack_desktop',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedLocation,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                    "name": nameController.text.trim(),
                                    "username": usernameController.text.trim(),
                                    "email": emailController.text.trim(),
                                    "cityId": selectedCityId,
                                    "latitude": selectedLocation.latitude,
                                    "longitude": selectedLocation.longitude,
                                    "contactPhone": contactPhoneController.text
                                        .trim(),
                                    "scoutMaster": scoutMasterController.text
                                        .trim(),
                                    "troopLeader": troopLeaderController.text
                                        .trim(),
                                    "foundingDate": parseDate(
                                      foundingDateController.text,
                                    ).toIso8601String(),
                                  };

                                  final troopProvider =
                                      Provider.of<TroopProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final updatedTroop = await troopProvider
                                      .update(_troop.id, requestBody);

                                  final refreshedTroop = await troopProvider
                                      .getById(_troop.id);

                                  isUpdated = true;

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Odred "${refreshedTroop.name}" je ažuriran.',
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
        final troopProvider = Provider.of<TroopProvider>(
          context,
          listen: false,
        );
        final refreshedTroop = await troopProvider.getById(_troop.id);

        setState(() {
          _troop = refreshedTroop;
          if (refreshedTroop.latitude != null &&
              refreshedTroop.longitude != null) {
            _selectedLocation = LatLng(
              refreshedTroop.latitude!,
              refreshedTroop.longitude!,
            );
          }
        });
      } catch (e) {
        if (context.mounted) showErrorSnackbar(context, e);
      }
    }

    return isUpdated;
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
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Unesite novu lozinku';
                            if (v.length < 8) return 'Najmanje 8 znakova';
                            if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
                            ).hasMatch(v)) {
                              return 'Mora imati veliko, malo slovo, broj i spec. znak';
                            }
                            return null;
                          },
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
                        final provider = Provider.of<TroopProvider>(
                          context,
                          listen: false,
                        );
                        await provider.changePassword(_troop.id, {
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

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
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

  Future<void> _showImagePickerDialog() async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Promijeni sliku odreda'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImageBytes != null || _troop.logoUrl.isNotEmpty)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : (_troop.logoUrl.isNotEmpty
                                      ? Image.network(
                                          _troop.logoUrl,
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
                                          child: Icon(Icons.image, size: 50),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
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
                    child: const Text('Odaberi sliku'),
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

      final troopProvider = Provider.of<TroopProvider>(context, listen: false);
      final updatedTroop = await troopProvider.updateLogo(_troop.id, imageFile);

      final refreshedTroop = await troopProvider.getById(_troop.id);

      setState(() {
        _troop = refreshedTroop;
        if (_troop.latitude != null && _troop.longitude != null) {
          _selectedLocation = LatLng(_troop.latitude!, _troop.longitude!);
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slika je uspješno promijenjena.')),
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

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = _troop.latitude != null && _troop.longitude != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return MasterScreen(
      selectedMenu: widget.selectedMenu,
      role: _role,
      title: 'Odred izviđača "${_troop.name}"',
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
                                child: _troop.logoUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _troop.logoUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.group,
                                                  size: 50,
                                                  color: Colors.white,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.group,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                              ),
                              if ((isAdmin || isViewingOwnProfile) &&
                                  _troop.logoUrl.isNotEmpty &&
                                  !_isImageLoading)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Obriši logo'),
                                          content: const Text(
                                            'Jeste li sigurni da želite obrisati logo odreda?',
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

                                          final troopProvider =
                                              Provider.of<TroopProvider>(
                                                context,
                                                listen: false,
                                              );
                                          await troopProvider.updateLogo(
                                            _troop.id,
                                            null,
                                          );

                                          final refreshedTroop =
                                              await troopProvider.getById(
                                                _troop.id,
                                              );

                                          setState(() {
                                            _troop = refreshedTroop;
                                          });

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Logo je uspješno obrisan.',
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
                          if (isAdmin || isViewingOwnProfile)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.image, size: 16),
                              label: const Text('Promijeni sliku'),
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
                            _troop.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _troop.cityName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              UIComponents.buildInfoChip(
                                'Članovi: ${_troop.memberCount}',
                                Icons.people,
                              ),
                              const SizedBox(width: 16),
                              UIComponents.buildInfoChip(
                                _troop.isActive ? 'Aktivan' : 'Neaktivan',
                                _troop.isActive
                                    ? Icons.check_circle
                                    : Icons.block,
                                color: _troop.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 40),

                      if (isAdmin || isViewingOwnProfile)
                        Column(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Uredi podatke'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(180, 48),
                              ),
                              onPressed: () async {
                                _onEdit();
                              },
                            ),
                            const SizedBox(height: 16),
                            if (isViewingOwnProfile)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.password, size: 20),
                                label: const Text('Promijeni lozinku'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(180, 48),
                                ),
                                onPressed: _showChangePasswordDialog,
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(
                                _troop.isActive
                                    ? Icons.block
                                    : Icons.check_circle,
                              ),
                              label: Text(
                                _troop.isActive ? 'Deaktiviraj' : 'Aktiviraj',
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(180, 48),
                                backgroundColor: _troop.isActive
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
                      UIComponents.buildDetailSection('Kontakt informacije', [
                        UIComponents.buildDetailRow(
                          'E-mail',
                          _troop.email,
                          Icons.email,
                        ),
                        UIComponents.buildDetailRow(
                          'Telefon',
                          _troop.contactPhone,
                          Icons.phone,
                        ),
                        UIComponents.buildDetailRow(
                          'Korisničko ime',
                          _troop.username,
                          Icons.person,
                        ),
                        UIComponents.buildDetailRow(
                          'Starješina',
                          _troop.scoutMaster,
                          Icons.person,
                        ),
                        UIComponents.buildDetailRow(
                          'Načelnik',
                          _troop.troopLeader,
                          Icons.person,
                        ),
                        UIComponents.buildDetailRow(
                          'Datum osnivanja',
                          formatDate(_troop.foundingDate),
                          Icons.calendar_today,
                        ),
                      ]),

                      const SizedBox(height: 30),
                      if (isAdmin || isViewingOwnProfile)
                        UIComponents.buildDetailSection('Sistem informacije', [
                          UIComponents.buildDetailRow(
                            'Kreiran',
                            formatDateTime(_troop.createdAt),
                          ),
                          if (_troop.updatedAt != null)
                            UIComponents.buildDetailRow(
                              'Izmijenjen',
                              formatDateTime(_troop.updatedAt!),
                            ),
                          if (_troop.lastLoginAt != null)
                            UIComponents.buildDetailRow(
                              'Zadnja prijava',
                              formatDateTime(_troop.lastLoginAt!),
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
                      SizedBox(
                        height: 280,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: hasCoordinates
                                ? FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      center: _selectedLocation,
                                      zoom: 13.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.scouttrack_desktop',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _selectedLocation!,
                                            width: 50,
                                            height: 50,
                                            child: const Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 50,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                      'Nema dostupnih koordinata',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UIComponents.buildBigActionButton(
                            icon: Icons.people,
                            label: 'Članovi',
                            color: Colors.blue,
                            onPressed: _navigateToMembers,
                          ),
                          const SizedBox(width: 24),
                          UIComponents.buildBigActionButton(
                            icon: Icons.event,
                            label: 'Aktivnosti',
                            color: Colors.green,
                            onPressed: _navigateToActivities,
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

  _navigateToMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberListScreen(initialTroopId: _troop.id),
      ),
    );
  }

  _navigateToActivities() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityListScreen(initialTroopId: _troop.id),
      ),
    );
  }
}
