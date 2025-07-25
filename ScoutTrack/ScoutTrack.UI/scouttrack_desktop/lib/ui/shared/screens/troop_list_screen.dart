import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_details_screen.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_picker_dialog.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class TroopListScreen extends StatefulWidget {
  const TroopListScreen({super.key});

  @override
  State<TroopListScreen> createState() => _TroopListScreenState();
}

class _TroopListScreenState extends State<TroopListScreen> {
  SearchResult<Troop>? _troops;
  bool _loading = false;
  String? _error;
  String? _role;
  final ScrollController _scrollController = ScrollController();
  int? _selectedCityId;
  String? _selectedSort;
  List<City> _cities = [];

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late TroopProvider _troopProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _troopProvider = TroopProvider(authProvider);
    _loadInitialData();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = await authProvider.getUserRole();
    setState(() {
      _role = role;
    });
    final cityProvider = CityProvider(authProvider);
    var filter = { "RetrieveAll": true };
    final cityResult = await cityProvider.get(filter: filter);
    setState(() {
    _cities = cityResult.items ?? [];
    });
    await _fetchTroops();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
      });
      _fetchTroops();
    });
  }

  Future<void> _fetchTroops({int? page}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var filter = {
        if (searchController.text.isNotEmpty) "Name": searchController.text,
        if (_selectedCityId != null) "CityId": _selectedCityId,
        if (_selectedSort != null) "OrderBy": _selectedSort,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
        };
      var result = await _troopProvider.get(filter: filter);

      setState(() {
        _troops = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _troops = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? '',
      selectedMenu: 'Odredi',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Pretraži odrede...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedCityId,
                      decoration: const InputDecoration(
                        labelText: 'Grad',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                          currentPage = 1;
                        });
                        _fetchTroops();
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Svi gradovi"),
                        ),
                        ..._cities.map((city) => DropdownMenuItem(
                          value: city.id,
                          child: Text(city.name),
                        )),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String?>(
                      value: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Sortiraj',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                          currentPage = 1;
                        });
                        _fetchTroops();
                      },
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Bez sortiranja'),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('Naziv (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-name',
                          child: Text('Naziv (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'memberCount',
                          child: Text('Broj članova (rastuće)'),
                        ),
                        DropdownMenuItem(
                          value: '-memberCount',
                          child: Text('Broj članova (opadajuće)'),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_role == 'Admin')
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton.icon(
                      onPressed: _onAddTroop,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Dodaj novi odred',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResultView()),
            const SizedBox(height: 8),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_loading && _troops == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Greška pri učitavanju: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_troops == null || _troops!.items == null || _troops!.items!.isEmpty) {
      return const Center(
        child: Text(
          'Nema dostupnih odreda',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade100,
                ),
                columnSpacing: 32,
                columns: const [
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('NAZIV'),
                )),
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('KORISNIČKO IME'),
                )),
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('E-MAIL'),
                )),
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('GRAD'),
                )),
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('BROJ ČLANOVA'),
                )),
                DataColumn(label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('AKTIVAN'),
                )),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                ],
                rows: _troops!.items!.map((troop) {
                return DataRow(
                    cells: [
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(troop.name),
                    )),
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(troop.username),
                    )),
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(troop.email),
                    )),
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(troop.cityName),
                    )),
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(troop.memberCount.toString()),
                    )),
                    DataCell(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: troop.isActive ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red),
                    )),
                    if (_role == 'Admin') ...[
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.grey),
                          tooltip: 'Detalji',
                          onPressed: () => _navigateToTroopDetails(troop),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Uredi',
                          onPressed: () => _onEditTroop(troop),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Obriši',
                          onPressed: () => _onDeleteTroop(troop),
                        ),
                      ),
                    ] else ...[
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.grey),
                          tooltip: 'Detalji',
                          onPressed: () => _navigateToTroopDetails(troop),
                        ),
                      ),
                      const DataCell(SizedBox()),
                      const DataCell(SizedBox()), 
                    ],
                  ]
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int maxPageButtons = 5;
    int safeTotalPages = totalPages > 0 ? totalPages : 1;
    int safeCurrentPage = currentPage > 0 ? currentPage : 1;
    int startPage = (safeCurrentPage - (maxPageButtons ~/ 2)).clamp(1, (safeTotalPages - maxPageButtons + 1).clamp(1, safeTotalPages));
    int endPage = (startPage + maxPageButtons - 1).clamp(1, safeTotalPages);
    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];
    bool hasResults = (_troops?.totalCount ?? 0) > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: hasResults && safeCurrentPage > 1 ? () => _fetchTroops(page: 1) : null,
          ),
          TextButton(
            onPressed: hasResults && safeCurrentPage > 1 ? () => _fetchTroops(page: safeCurrentPage - 1) : null,
            child: const Text('Prethodna'),
          ),
          ...pageNumbers.map((page) => TextButton(
                onPressed: hasResults && page != safeCurrentPage ? () => _fetchTroops(page: page) : null,
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontWeight: page == safeCurrentPage ? FontWeight.bold : FontWeight.normal,
                    color: page == safeCurrentPage ? Colors.blue : Colors.black,
                  ),
                ),
              )),
          TextButton(
            onPressed: hasResults && safeCurrentPage < safeTotalPages ? () => _fetchTroops(page: safeCurrentPage + 1) : null,
            child: const Text('Sljedeća'),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: hasResults && safeCurrentPage < safeTotalPages ? () => _fetchTroops(page: safeTotalPages) : null,
          ),
        ],
      ),
    );
  }

  void _onAddTroop() {
    _showTroopDialog();
  }

  void _onEditTroop(Troop troop) {
    _showTroopDialog(troop: troop);
  }

  Future<void> _onDeleteTroop(Troop troop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text('Jeste li sigurni da želite obrisati odred ${troop.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _troopProvider.delete(troop.id);
        await _fetchTroops();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Odred ${troop.name} je obrisan.')),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _navigateToTroopDetails(Troop troop) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userInfo = await authProvider.getCurrentUserInfo();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TroopDetailsScreen(
          troop: troop,
          role: userInfo?['role'] ?? '',
          loggedInUserId: userInfo?['id'] ?? 0,
          selectedMenu: 'Odredi',
        ),
      ),
    );

    if (result == true) {
      await _fetchTroops();
    }
  }

  Future<void> _showTroopDialog({Troop? troop}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: troop?.name ?? '');
    final TextEditingController usernameController = TextEditingController(text: troop?.username ?? '');
    final TextEditingController emailController = TextEditingController(text: troop?.email ?? '');
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController contactPhoneController = TextEditingController(text: troop?.contactPhone ?? '');
    XFile? selectedImage;
    Uint8List? imageBytes;
    
    LatLng selectedLocation = (troop?.latitude != null && troop?.longitude != null)
        ? LatLng(troop!.latitude!, troop.longitude!)
        : const LatLng(43.8563, 18.4131);
    
    int? selectedCityId = troop?.cityId;
    String? selectedCityName;
    final isEdit = troop != null;
    final MapController _mapController = MapController();

    if (isEdit && troop?.cityId != null) {
      selectedCityName = _cities.firstWhere((c) => c.id == troop?.cityId).name;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<Uint8List> _compressImage(Uint8List bytes, {int quality = 30, int maxWidth = 800}) async {
              try {
                final image = img.decodeImage(bytes);
                if (image == null) return bytes;

                int width = image.width;
                int height = image.height;
                if (width > maxWidth) {
                  height = (height * maxWidth / width).round();
                  width = maxWidth;
                }

                final resizedImage = img.copyResize(image, width: width, height: height);
                final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

                return Uint8List.fromList(compressedBytes);
              } catch (e) {
                return bytes;
              }
            }

            Future<void> _pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                try {
                  final bytes = await pickedFile.readAsBytes();
                  final compressedBytes = await _compressImage(bytes);

                  print('Compressed size: ${compressedBytes.length / 1024} KB');
                  
                  setState(() {
                    selectedImage = pickedFile;
                    imageBytes = compressedBytes;
                  });
                } catch (e) {
                  showErrorSnackbar(context, e);
                }
              }
            }

            void _removeImage() {
              setState(() {
                selectedImage = null;
                imageBytes = null;
              });
            }

            Future<void> _openMapPicker() async {
              final initialLocation = selectedLocation ?? const LatLng(43.8563, 18.4131);
              
              final result = await showDialog<Map<String, double>>(
                context: context,
                builder: (context) => MapPickerDialog(
                  initialLocation: initialLocation,
                ),
              );

              if (result != null) {
                final newLocation = LatLng(result['latitude']!, result['longitude']!);
                setState(() {
                  selectedLocation = newLocation;
                });
                _mapController.move(newLocation, _mapController.zoom);
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
                      Text(
                        isEdit ? 'Uredi odred' : 'Dodaj odred',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                final regex = RegExp(r"^[A-Za-zčćžšđČĆŽŠĐ\s-]+$");
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Naziv smije sadržavati samo slova, razmake i crtice.';
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
                                if (!RegExp(r"^[A-Za-z0-9_.]+$").hasMatch(value.trim())) {
                                  return 'Dozvoljena su slova, brojevi, tačka i donja crta';
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
                            if (!isEdit) ...[
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'Lozinka'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Lozinka je obavezna.';
                                  if (value.length < 8) return 'Lozinka mora imati najmanje 8 znakova.';
                                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])').hasMatch(value)) {
                                    return 'Lozinka mora sadržavati velika i mala slova, broj i spec. znak.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
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
                             if (!isEdit) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Logo odreda:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  if (imageBytes != null)
                                    Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(imageBytes!, fit: BoxFit.cover),
                                      ),
                                    ),
                                  if (imageBytes != null) const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.image),
                                        label: const Text('Odaberi sliku'),
                                        onPressed: _pickImage,
                                      ),
                                      if (imageBytes != null) ...[
                                        const SizedBox(width: 16),
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          label: const Text('Ukloni', style: TextStyle(color: Colors.red)),
                                          onPressed: _removeImage,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 24),
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
                                    urlTemplate: 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
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
                                if (selectedLocation == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Molimo odaberite lokaciju na mapi')),
                                  );
                                  return;
                                }

                                try {
                                  final requestBody = {
                                    "name": nameController.text.trim(),
                                    "username": usernameController.text.trim(),
                                    "email": emailController.text.trim(),
                                    if (!isEdit) "password": passwordController.text.trim(),
                                    "cityId": selectedCityId,
                                    "latitude": selectedLocation.latitude,
                                    "longitude": selectedLocation.longitude,
                                    "contactPhone": contactPhoneController.text.trim(),
                                  };

                                  if (isEdit) {
                                    await _troopProvider.update(troop!.id, requestBody);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Odred "${troop.name}" je ažuriran.')),
                                    );
                                  } else {
                                    final createdTroop = await _troopProvider.insert(requestBody);

                                    if (selectedImage != null) {
                                      final imageUrl = await _troopProvider.updateLogo(
                                        createdTroop.id,
                                        File(selectedImage!.path),
                                      );
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Odred je dodan.')),
                                    );
                                  }

                                  await _fetchTroops();
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  showErrorSnackbar(context, e);
                                }
                              }
                            },

                            child: Text(isEdit ? 'Sačuvaj' : 'Dodaj'),
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
  }
}