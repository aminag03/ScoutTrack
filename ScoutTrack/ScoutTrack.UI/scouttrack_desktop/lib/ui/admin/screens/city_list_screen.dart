import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_picker_dialog.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  SearchResult<City>? _cities;
  bool _loading = false;
  String? _error;
  String? _role;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late CityProvider _cityProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _cityProvider = CityProvider(authProvider);
    _loadInitialData();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
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

    if (role == 'Admin') {
      await _fetchCities();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
      });
      _fetchCities();
    });
  }

  Future<void> _fetchCities({int? page}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var filter = {
        if (searchController.text.isNotEmpty) "Name": searchController.text,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };

      var result = await _cityProvider.get(filter: filter);

      setState(() {
        _cities = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cities = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role != 'Admin') {
      return MasterScreen(
        role: _role!,
        child: const Center(
          child: Text(
            'Nemate ovlasti za pristup ovoj stranici.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return MasterScreen(
      role: _role!,
      selectedMenu: 'Gradovi',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Pretraži...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _onAddCity,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Dodaj novi grad',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    if (_loading && _cities == null) {
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

    if (_cities == null || _cities!.items == null || _cities!.items!.isEmpty) {
      return const Center(
        child: Text(
          'Nema dostupnih gradova',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
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
                child: Text('VRIJEME KREIRANJA'),
              )),
              DataColumn(label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('VRIJEME IZMJENE'),
              )),
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
            ],
            rows: _cities!.items!.map((city) {
              return DataRow(
                cells: [
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(city.name),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(formatDateTime(city.createdAt)),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      city.updatedAt != null
                          ? formatDateTime(city.updatedAt!)
                          : '-',
                    ),
                  )),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Uredi',
                      onPressed: () => _onEditCity(city),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Obriši',
                      onPressed: () => _onDeleteCity(city),
                    ),
                  ),
                ],
              );
            }).toList(),
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

    bool hasResults = (_cities?.totalCount ?? 0) > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: hasResults && safeCurrentPage > 1 ? () => _fetchCities(page: 1) : null,
          ),

          TextButton(
            onPressed: hasResults && safeCurrentPage > 1 ? () => _fetchCities(page: safeCurrentPage - 1) : null,
            child: const Text('Prethodna'),
          ),

          ...pageNumbers.map((page) => TextButton(
                onPressed: hasResults && page != safeCurrentPage ? () => _fetchCities(page: page) : null,
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontWeight: page == safeCurrentPage ? FontWeight.bold : FontWeight.normal,
                    color: page == safeCurrentPage ? Colors.blue : Colors.black,
                  ),
                ),
              )),

          TextButton(
            onPressed: hasResults && safeCurrentPage < safeTotalPages ? () => _fetchCities(page: safeCurrentPage + 1) : null,
            child: const Text('Sljedeća'),
          ),

          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: hasResults && safeCurrentPage < safeTotalPages ? () => _fetchCities(page: safeTotalPages) : null,
          ),
        ],
      ),
    );
  }

  void _onAddCity() {
    _showCityDialog();
  }

  void _onEditCity(City city) {
    _showCityDialog(city: city);
  }

  Future<void> _onDeleteCity(City city) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text('Jeste li sigurni da želite obrisati grad ${city.name}?'),
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
        await _cityProvider.delete(city.id);
        await _fetchCities();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grad ${city.name} je obrisan.')),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _showCityDialog({City? city}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = 
        TextEditingController(text: city?.name ?? '');
    
    LatLng selectedLocation = (city?.latitude != null && city?.longitude != null)
        ? LatLng(city!.latitude!, city.longitude!)
        : LatLng(43.8563, 18.4131); // Default to Sarajevo coordinates

    final isEdit = city != null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _openMapPicker() async {
              final initialLocation = selectedLocation;
              
              final result = await showDialog<Map<String, double>>(
                context: context,
                builder: (context) => MapPickerDialog(
                  initialLocation: initialLocation,
                ),
              );

              if (result != null) {
                setState(() {
                  selectedLocation = LatLng(result['latitude']!, result['longitude']!);
                });
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
                        isEdit ? 'Uredi grad' : 'Dodaj grad',
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
                                  return 'Naziv grada smije sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Lokacija grada:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedLocation != null
                                  ? 'Odabrana lokacija: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}'
                                  : 'Nije odabrana lokacija',
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 300,
                              child: FlutterMap(
                                options: MapOptions(
                                  center: selectedLocation ?? const LatLng(43.8563, 18.4131),
                                  zoom: selectedLocation != null ? 10 : 6,
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
                                  if (selectedLocation != null)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: selectedLocation!,
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
                                    "latitude": selectedLocation!.latitude,
                                    "longitude": selectedLocation!.longitude,
                                  };
                                  
                                  if (isEdit) {
                                    await _cityProvider.update(city!.id, requestBody);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Grad "${city.name}" je ažuriran.')),
                                    );
                                  } else {
                                    await _cityProvider.insert(requestBody);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Grad je dodan.')),
                                    );
                                  }
                                  await _fetchCities();
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