import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_picker_dialog.dart';
import 'package:scouttrack_desktop/utils/pdf_report_utils.dart';

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
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

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
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
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

  Future<void> _generateReport() async {
    try {
      setState(() {
        _loading = true;
      });

      var filter = {"RetrieveAll": true, "IncludeTotalCount": true};

      var result = await _cityProvider.get(filter: filter);

      if (result.items != null && result.items!.isNotEmpty) {
        final filePath = await PdfReportUtils.generateCityReport(
          result.items!,
          filters: filter,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PDF izvještaj je uspješno generiran!'),
                  const SizedBox(height: 4),
                  Text(
                    'Datoteka spremljena u: $filePath',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nema podataka za generiranje izvještaja.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
                  onPressed: _loading ? null : _generateReport,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    _loading ? 'Generiranje...' : 'Generiši izvještaj',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_cities != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prikazano ${_cities!.items?.length ?? 0} od ukupno ${_cities!.totalCount ?? 0} gradova',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(child: _buildResultView()),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PaginationControls(
                currentPage: currentPage,
                totalPages: totalPages,
                totalCount: _cities?.totalCount ?? 0,
                onPageChanged: (page) => _fetchCities(page: page),
              ),
            ),
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
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade100,
                  ),
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('NAZIV'),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VRIJEME KREIRANJA'),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VRIJEME IZMJENE'),
                      ),
                    ),
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('')),
                  ],
                  rows: _cities!.items!.map((city) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(city.name),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(formatDateTime(city.createdAt)),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              city.updatedAt != null
                                  ? formatDateTime(city.updatedAt!)
                                  : '-',
                            ),
                          ),
                        ),
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
          ),
        ),
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

        final currentItemsOnPage = _cities?.items?.length ?? 0;
        final newTotalCount = (_cities?.totalCount ?? 0) - 1;
        final newTotalPages = (newTotalCount / pageSize).ceil();

        if (currentItemsOnPage == 1 && currentPage > 1) {
          await _fetchCities(page: currentPage - 1);
        } else {
          await _fetchCities();
        }

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
    final TextEditingController nameController = TextEditingController(
      text: city?.name ?? '',
    );

    LatLng selectedLocation =
        (city?.latitude != null && city?.longitude != null)
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
                builder: (context) =>
                    MapPickerDialog(initialLocation: initialLocation),
              );

              if (result != null) {
                setState(() {
                  selectedLocation = LatLng(
                    result['latitude']!,
                    result['longitude']!,
                  );
                });
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
                      Text(
                        isEdit ? 'Uredi grad' : 'Dodaj grad',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Naziv',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Naziv je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'Naziv ne smije imati više od 100 znakova.';
                                }
                                final regex = RegExp(
                                  r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$",
                                );
                                if (!regex.hasMatch(value.trim())) {
                                  return 'Naziv grada može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                  center:
                                      selectedLocation ??
                                      const LatLng(43.8563, 18.4131),
                                  zoom: selectedLocation != null ? 10 : 6,
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (selectedLocation == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Molimo odaberite lokaciju na mapi',
                                      ),
                                    ),
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
                                    await _cityProvider.update(
                                      city!.id,
                                      requestBody,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Grad "${city.name}" je ažuriran.',
                                        ),
                                      ),
                                    );
                                    await _fetchCities(page: currentPage);
                                  } else {
                                    await _cityProvider.insert(requestBody);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Grad je dodan.'),
                                      ),
                                    );
                                    final newTotalCount =
                                        (_cities?.totalCount ?? 0) + 1;
                                    final newTotalPages =
                                        (newTotalCount / pageSize).ceil();
                                    await _fetchCities(page: newTotalPages);
                                  }
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
