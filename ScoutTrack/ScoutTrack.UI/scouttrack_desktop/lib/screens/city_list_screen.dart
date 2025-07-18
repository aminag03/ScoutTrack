import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  @override
  State<CitiesPage> createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
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
        color: Colors.white,
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
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Dodaj novi grad',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8055),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResultView()),
            const SizedBox(height: 8),
            // Always show pagination at the bottom, even if no results
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
                child: Text('DATUM KREIRANJA'),
              )),
              DataColumn(label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('DATUM IZMJENE'),
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
                    child: Text(_formatDate(city.createdAt)),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      city.updatedAt != null
                          ? _formatDate(city.updatedAt!)
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

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  Future<void> _showCityDialog({City? city}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: city?.name ?? '');

    final isEdit = city != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Uredi grad' : 'Dodaj grad'),
          content: Form(
            key: _formKey,
            child: TextFormField(
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    final requestBody = {"name": nameController.text.trim()};
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
                    Navigator.of(context).pop();
                    showErrorSnackbar(context, e);
                  }
                }
              },
              child: Text(isEdit ? 'Sačuvaj' : 'Dodaj'),
            ),
          ],
        );
      },
    );
  }
}