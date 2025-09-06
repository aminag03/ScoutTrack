import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/equipment_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/pdf_report_utils.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  SearchResult<Equipment>? _equipment;
  bool _loading = false;
  String? _error;
  String? _role;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool _showOnlyGlobal = false;
  bool _showOnlyLocal = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late EquipmentProvider _equipmentProvider;
  late TroopProvider _troopProvider;
  Map<int, String> _troopNames = {};

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _equipmentProvider = EquipmentProvider(authProvider);
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
    if (!mounted) return;
    setState(() {
      _role = role;
    });

    if (role == 'Admin') {
      await _fetchEquipment();
      await _loadTroopNames();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        currentPage = 1;
      });
      _fetchEquipment();
    });
  }

  Future<void> _fetchEquipment({int? page}) async {
    if (_loading) return;
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var filter = {
        if (searchController.text.isNotEmpty) "FTS": searchController.text,
        if (_showOnlyGlobal) "IsGlobal": true,
        if (_showOnlyLocal) "IsGlobal": false,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };

      var result = await _equipmentProvider.get(filter: filter);

      if (!mounted) return;
      setState(() {
        _equipment = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _equipment = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadTroopNames() async {
    try {
      var troops = await _troopProvider.get();
      if (!mounted) return;
      if (troops.items != null) {
        setState(() {
          _troopNames = {for (var troop in troops.items!) troop.id: troop.name};
        });
      }
    } catch (e) {
      print('Failed to load troop names: $e');
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
      selectedMenu: 'Oprema',
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
                    _loading ? 'Generisanje...' : 'Generiši izvještaj',
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
                  onPressed: _onAddEquipment,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Dodaj novu opremu',
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
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Filter: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Globalna'),
                        selected: _showOnlyGlobal,
                        onSelected: (selected) {
                          setState(() {
                            _showOnlyGlobal = selected;
                            if (selected) _showOnlyLocal = false;
                            currentPage = 1;
                          });
                          _fetchEquipment();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Lokalna'),
                        selected: _showOnlyLocal,
                        onSelected: (selected) {
                          setState(() {
                            _showOnlyLocal = selected;
                            if (selected) _showOnlyGlobal = false;
                            currentPage = 1;
                          });
                          _fetchEquipment();
                        },
                      ),
                      const SizedBox(width: 8),
                      if (_showOnlyGlobal || _showOnlyLocal)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showOnlyGlobal = false;
                              _showOnlyLocal = false;
                              currentPage = 1;
                            });
                            _fetchEquipment();
                          },
                          child: const Text('Očisti filter'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_equipment != null)
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
                      'Prikazano ${_equipment!.items?.length ?? 0} od ukupno ${_equipment!.totalCount ?? 0} opreme',
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
            const SizedBox(height: 16),
            PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              totalCount: _equipment?.totalCount ?? 0,
              onPageChanged: (page) => _fetchEquipment(page: page),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_loading && _equipment == null) {
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

    if (_equipment == null ||
        _equipment!.items == null ||
        _equipment!.items!.isEmpty) {
      return const Center(
        child: Text(
          'Nema dostupne opreme',
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
                constraints: const BoxConstraints(minWidth: 1200),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade100,
                  ),
                  columnSpacing: 32,
                  dataRowHeight: 48,
                  headingRowHeight: 48,
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
                        child: Text('OPIS'),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('STATUS'),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('KREIRAO ODRED'),
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
                    DataColumn(label: Text('')),
                  ],
                  rows: _equipment!.items!.map((equipment) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(equipment.name),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Tooltip(
                              message: equipment.description.isNotEmpty
                                  ? equipment.description
                                  : 'Nema opisa',
                              child: Text(
                                equipment.description.isNotEmpty
                                    ? (equipment.description.length > 50
                                          ? '${equipment.description.substring(0, 50)}...'
                                          : equipment.description)
                                    : '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: equipment.isGlobal
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                equipment.isGlobal ? 'Globalna' : 'Lokalna',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              equipment.createdByTroopId != null
                                  ? _troopNames[equipment.createdByTroopId] ??
                                        'Nepoznat odred'
                                  : '-',
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(formatDateTime(equipment.createdAt)),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              equipment.updatedAt != null
                                  ? formatDateTime(equipment.updatedAt!)
                                  : '-',
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Uredi',
                            onPressed: () => _onEditEquipment(equipment),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Obriši',
                            onPressed: () => _onDeleteEquipment(equipment),
                          ),
                        ),
                        DataCell(
                          !equipment.isGlobal
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.public,
                                    color: Colors.green,
                                  ),
                                  tooltip: 'Učini globalnom',
                                  onPressed: () => _onMakeGlobal(equipment),
                                )
                              : const SizedBox.shrink(),
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

  void _onAddEquipment() {
    _showEquipmentDialog();
  }

  void _onEditEquipment(Equipment equipment) {
    _showEquipmentDialog(equipment: equipment);
  }

  Future<void> _onDeleteEquipment(Equipment equipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati opremu ${equipment.name}?',
        ),
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
        await _equipmentProvider.delete(equipment.id);

        final currentItemsOnPage = _equipment?.items?.length ?? 0;
        final newTotalCount = (_equipment?.totalCount ?? 0) - 1;
        final newTotalPages = (newTotalCount / pageSize).ceil();

        if (currentItemsOnPage == 1 && currentPage > 1) {
          await _fetchEquipment(page: currentPage - 1);
        } else {
          await _fetchEquipment();
        }

        showSuccessSnackbar(context, 'Oprema ${equipment.name} je obrisana.');
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onMakeGlobal(Equipment equipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda promjene'),
        content: Text(
          'Jeste li sigurni da želite učiniti opremu "${equipment.name}" globalnom? Ova akcija će ukloniti povezanost s odredom.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Učini globalnom',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _equipmentProvider.makeGlobal(equipment.id);
        await _fetchEquipment();
        showSuccessSnackbar(
          context,
          'Oprema "${equipment.name}" je sada globalna.',
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _showEquipmentDialog({Equipment? equipment}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: equipment?.name ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: equipment?.description ?? '',
    );

    final isEdit = equipment != null;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Uredi opremu' : 'Dodaj opremu',
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
                          decoration: const InputDecoration(labelText: 'Naziv'),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                          maxLines: 3,
                          validator: (value) {
                            if (value != null && value.length > 500) {
                              return 'Opis ne smije imati više od 500 znakova.';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            try {
                              final requestBody = {
                                "name": nameController.text.trim(),
                                "description": descriptionController.text
                                    .trim(),
                              };

                              if (isEdit) {
                                await _equipmentProvider.update(
                                  equipment!.id,
                                  requestBody,
                                );
                                showSuccessSnackbar(
                                  context,
                                  'Oprema "${equipment.name}" je ažurirana.',
                                );
                              } else {
                                await _equipmentProvider.insert(requestBody);
                                showSuccessSnackbar(
                                  context,
                                  'Oprema je dodana.',
                                );
                              }
                              final newTotalCount =
                                  (_equipment?.totalCount ?? 0) + 1;
                              final newTotalPages = (newTotalCount / pageSize)
                                  .ceil();
                              await _fetchEquipment(page: newTotalPages);
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
  }

  Future<void> _generateReport() async {
    try {
      setState(() {
        _loading = true;
      });

      var filter = {"RetrieveAll": true, "IncludeTotalCount": true};

      var result = await _equipmentProvider.get(filter: filter);

      if (result.items != null && result.items!.isNotEmpty) {
        final filePath = await PdfReportUtils.generateEquipmentReport(
          result.items!,
          filters: filter,
          troopNames: _troopNames,
        );

        if (mounted) {
          showCustomSnackbar(
            context,
            message:
                'PDF izvještaj je uspješno generisan!\nDatoteka spremljena u: $filePath',
            backgroundColor: Colors.green,
            icon: Icons.picture_as_pdf,
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        if (mounted) {
          showCustomSnackbar(
            context,
            message: 'Nema podataka za generisanje izvještaja.',
            backgroundColor: Colors.orange,
            icon: Icons.warning,
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
}
