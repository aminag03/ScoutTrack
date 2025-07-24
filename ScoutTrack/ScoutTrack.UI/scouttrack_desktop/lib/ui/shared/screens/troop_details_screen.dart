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
      var filter = { "RetrieveAll": true };
      final cityResult = await cityProvider.get(filter: filter);
      setState(() {
        _cities = cityResult.items ?? [];
      });
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, e);
      }
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
      if (context.mounted) {
        showErrorSnackbar(context, e);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onEdit() async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: _troop.name);
    final TextEditingController usernameController = TextEditingController(text: _troop.username);
    final TextEditingController emailController = TextEditingController(text: _troop.email);
    final TextEditingController contactPhoneController = TextEditingController(text: _troop.contactPhone);
    final TextEditingController logoUrlController = TextEditingController(text: _troop.logoUrl);
    final MapController _mapController = MapController();
    
    LatLng selectedLocation = _selectedLocation ?? const LatLng(43.8563, 18.4131);
    int? selectedCityId = _troop.cityId;
    String? selectedCityName;
    bool isUpdated = false;

    if (_troop.cityId != null) {
      selectedCityName = _cities.firstWhere((c) => c.id == _troop.cityId).name;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _openMapPicker() async {
              final initialLocation = selectedLocation;
              
              final result = await showDialog<Map<String, double>>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Odaberite lokaciju'),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: initialLocation,
                        zoom: 10,
                        onTap: (tapPosition, point) {
                          Navigator.of(context).pop({
                            'latitude': point.latitude,
                            'longitude': point.longitude,
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.scouttrack_desktop',
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
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Otkaži'),
                    ),
                  ],
                ),
              );

              if (result != null) {
                final newLocation = LatLng(result['latitude']!, result['longitude']!);
                setState(() {
                  selectedLocation = newLocation;
                });
              }
            }

            void _updateCityLocation(int? cityId) {
              if (cityId != null) {
                final selectedCity = _cities.firstWhere((c) => c.id == cityId);
                if (selectedCity.latitude != null && selectedCity.longitude != null) {
                  final newLocation = LatLng(selectedCity.latitude!, selectedCity.longitude!);
                  setState(() {
                    selectedLocation = newLocation;
                  });
                  _mapController.move(newLocation, _mapController.zoom);
                }
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: 'Naziv'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Naziv je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'Naziv ne smije imati više od 100 znakova.';
                                }
                                final regex = RegExp(r"^[A-Za-z0-9čćžšđČĆŽŠĐ\s-']+$");
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Naziv smije sadržavati samo slova, brojeve razmake, crtice i apostrofe.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(labelText: 'Korisničko ime'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Korisničko ime je obavezno.';
                                }
                                if (value.length > 50) {
                                  return 'Korisničko ime ne smije imati više od 50 znakova.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'E-mail'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'E-mail je obavezan.';
                                }
                                if (!RegExp(r"^[\w-.]+@[\w-]+\.[a-zA-Z]{2,}").hasMatch(value.trim())) {
                                  return 'Unesite ispravan e-mail.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: contactPhoneController,
                              decoration: const InputDecoration(labelText: 'Kontakt telefon'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Telefon je obavezan.';
                                if (!RegExp(r'^\+?\d{6,20}$').hasMatch(value)) {
                                  return 'Unesite ispravan broj telefona.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedCityId,
                              decoration: const InputDecoration(labelText: 'Grad'),
                              items: _cities
                                  .map((c) => DropdownMenuItem<int>(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                  .toList(),
                              validator: (value) => value == null ? 'Grad je obavezan.' : null,
                              onChanged: (val) {
                                setState(() {
                                  selectedCityId = val;
                                  selectedCityName = _cities.firstWhere((c) => c.id == val).name;
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
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.scouttrack_desktop',
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: logoUrlController,
                              decoration: const InputDecoration(labelText: 'Logo URL (opcionalno)'),
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
                                    "contactPhone": contactPhoneController.text.trim(),
                                    "logoUrl": logoUrlController.text.trim(),
                                  };
                                  
                                  final troopProvider = Provider.of<TroopProvider>(context, listen: false);
                                  final updatedTroop = await troopProvider.update(_troop.id, requestBody);
                                  
                                  setState(() {
                                    _troop = updatedTroop;
                                    _selectedLocation = LatLng(updatedTroop.latitude!, updatedTroop.longitude!);
                                  });

                                  isUpdated = true;
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Odred "${_troop.name}" je ažuriran.')),
                                    );
                                  }
                                  
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  if (context.mounted) {
                                    showErrorSnackbar(context, e);
                                  }
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
                          validator: (v) => v == null || v.isEmpty ? 'Unesite staru lozinku' : null,
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
                            if (v == null || v.isEmpty) return 'Unesite novu lozinku';
                            if (v.length < 8) return 'Najmanje 8 znakova';
                            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(v)) {
                              return 'Mora imati veliko, malo slovo, broj i spec. znak';
                            }
                            return null;
                          },
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
                                  confirmPasswordVisible = !confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) =>
                              v != newPassController.text ? 'Lozinke se ne poklapaju' : null,
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
                        final provider = Provider.of<TroopProvider>(context, listen: false);
                        await provider.changePassword(_troop.id, {
                          'oldPassword': oldPassController.text,
                          'newPassword': newPassController.text,
                          'confirmNewPassword': confirmPassController.text,
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lozinka promijenjena. Preusmjeravanje...')),
                          );

                          await Future.delayed(const Duration(seconds: 2));

                          if (!context.mounted) return;

                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout();

                          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            final message = e.toString();
                            if (message.contains('Stara lozinka nije ispravna')) {
                              generalError = 'Stara lozinka nije ispravna.';
                            } else if (message.contains('Nova lozinka ne smije biti ista kao stara.')) {
                              generalError = 'Nova lozinka ne smije biti ista kao stara.';
                            } else if (message.contains('Lozinke se ne poklapaju')) {
                              generalError = 'Lozinke se ne poklapaju.';
                            } else {
                              generalError = message.replaceFirst('Greška: ', '');
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
    final String? imageUrl = _troop.logoUrl.isNotEmpty ? _troop.logoUrl : null;
    final hasCoordinates = _troop.latitude != null && _troop.longitude != null;

    return MasterScreen(
      selectedMenu: widget.selectedMenu,
      role: _role,
      title: _troop.name,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/scouttrack_logo.png') as ImageProvider,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _troop.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _troop.cityName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin || isViewingOwnProfile) ...[
                        SizedBox(
                          width: 160, // Fixed width for both buttons
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text('Uredi'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40), // Fixed height
                                ),
                                onPressed: () async {
                                  final isUpdated = await _onEdit();
                                  if (isUpdated && mounted) {
                                    setState(() {
                                      _mapController = MapController();
                                      if (_troop.latitude != null && _troop.longitude != null) {
                                        _selectedLocation = LatLng(_troop.latitude!, _troop.longitude!);
                                      }
                                    });
                                    
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (_selectedLocation != null) {
                                        _mapController.move(_selectedLocation!, 13.0);
                                      }
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              if (isViewingOwnProfile)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.password, size: 20),
                                  label: const Text('Promijeni lozinku'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40), // Fixed height
                                  ),
                                  onPressed: _showChangePasswordDialog,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildDetailRow('Korisničko ime', _troop.username),
                  _buildDetailRow('E-mail', _troop.email),
                  _buildDetailRow('Grad', _troop.cityName),
                  _buildDetailRow('Broj članova', _troop.memberCount.toString()),
                  _buildDetailRow('Kontakt telefon', _troop.contactPhone),
                  _buildDetailRow('Aktivan', _troop.isActive ? 'Da' : 'Ne'),
                  if (isAdmin || isViewingOwnProfile) ...[
                    _buildDetailRow('Kreiran', formatDateTime(_troop.createdAt)),
                    _buildDetailRow('Izmijenjen',  _troop.updatedAt != null ? formatDateTime(_troop.updatedAt!) : '-'),
                    _buildDetailRow('Zadnja prijava', _troop.lastLoginAt != null ? formatDateTime(_troop.lastLoginAt!) : '-'),
                  ],

                  const SizedBox(height: 24),
                  const Text('Lokacija:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: hasCoordinates
                            ? FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  center: _selectedLocation,
                                  zoom: 13.0,
                                  interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                  onTap: (tapPosition, point) {
                                    // Disable tap-to-change location in details view
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.scouttrack_desktop',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _selectedLocation!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(child: Text('Nema dostupnih koordinata')),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (isAdmin || isViewingOwnProfile)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        icon: Icon(_troop.isActive ? Icons.block : Icons.check_circle),
                        label: Text(_troop.isActive ? 'Deaktiviraj odred' : 'Aktiviraj odred'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _troop.isActive ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _isLoading ? null : _toggleActivation,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}