import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/activity_type.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/activity_type_provider.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/form_validation_utils.dart';

class ActivityTypeListScreen extends StatefulWidget {
  const ActivityTypeListScreen({super.key});

  @override
  State<ActivityTypeListScreen> createState() => _ActivityTypeListScreenState();
}

class _ActivityTypeListScreenState extends State<ActivityTypeListScreen> {
  SearchResult<ActivityType>? _activityTypes;
  bool _loading = false;
  String? _error;
  String? _role;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late ActivityTypeProvider _activityTypeProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _activityTypeProvider = ActivityTypeProvider(authProvider);
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
      await _fetchActivityTypes();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
      });
      _fetchActivityTypes();
    });
  }

  Future<void> _fetchActivityTypes({int? page}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var filter = {
        if (searchController.text.isNotEmpty) "FTS": searchController.text,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };

      var result = await _activityTypeProvider.get(filter: filter);

      setState(() {
        _activityTypes = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _activityTypes = null;
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
      selectedMenu: 'Tipovi aktivnosti',
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
                  onPressed: _onAddActivityType,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Dodaj novi tip aktivnosti',
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
    if (_loading && _activityTypes == null) {
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

    if (_activityTypes == null ||
        _activityTypes!.items == null ||
        _activityTypes!.items!.isEmpty) {
      return const Center(
        child: Text(
          'Nema dostupnih tipova aktivnosti',
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
            rows: _activityTypes!.items!.map((activityType) {
              return DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(activityType.name),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        activityType.description.isNotEmpty
                            ? activityType.description
                            : '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(formatDateTime(activityType.createdAt)),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        activityType.updatedAt != null
                            ? formatDateTime(activityType.updatedAt!)
                            : '-',
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Uredi',
                      onPressed: () => _onEditActivityType(activityType),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Obriši',
                      onPressed: () => _onDeleteActivityType(activityType),
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

    int startPage = (safeCurrentPage - (maxPageButtons ~/ 2)).clamp(
      1,
      (safeTotalPages - maxPageButtons + 1).clamp(1, safeTotalPages),
    );
    int endPage = (startPage + maxPageButtons - 1).clamp(1, safeTotalPages);
    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

    bool hasResults = (_activityTypes?.totalCount ?? 0) > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: hasResults && safeCurrentPage > 1
                ? () => _fetchActivityTypes(page: 1)
                : null,
          ),
          TextButton(
            onPressed: hasResults && safeCurrentPage > 1
                ? () => _fetchActivityTypes(page: safeCurrentPage - 1)
                : null,
            child: const Text('Prethodna'),
          ),
          ...pageNumbers.map(
            (page) => TextButton(
              onPressed: hasResults && page != safeCurrentPage
                  ? () => _fetchActivityTypes(page: page)
                  : null,
              child: Text(
                '$page',
                style: TextStyle(
                  fontWeight: page == safeCurrentPage
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: page == safeCurrentPage ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => _fetchActivityTypes(page: safeCurrentPage + 1)
                : null,
            child: const Text('Sljedeća'),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => _fetchActivityTypes(page: safeTotalPages)
                : null,
          ),
        ],
      ),
    );
  }

  void _onAddActivityType() {
    _showActivityTypeDialog();
  }

  void _onEditActivityType(ActivityType activityType) {
    _showActivityTypeDialog(activityType: activityType);
  }

  Future<void> _onDeleteActivityType(ActivityType activityType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati tip aktivnosti ${activityType.name}?',
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
        await _activityTypeProvider.delete(activityType.id);
        await _fetchActivityTypes();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tip aktivnosti ${activityType.name} je obrisan.'),
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _showActivityTypeDialog({ActivityType? activityType}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: activityType?.name ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: activityType?.description ?? '',
    );

    final isEdit = activityType != null;

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
                    isEdit ? 'Uredi tip aktivnosti' : 'Dodaj tip aktivnosti',
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
                          validator: (value) =>
                              FormValidationUtils.validateActivityTypeName(value, 'Naziv'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Opis'),
                          maxLines: 3,
                          validator: (value) =>
                              FormValidationUtils.validateActivityTypeDescription(value, 'Opis'),
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
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              final requestBody = {
                                "name": nameController.text.trim(),
                                "description": descriptionController.text
                                    .trim(),
                              };

                              if (isEdit) {
                                await _activityTypeProvider.update(
                                  activityType!.id,
                                  requestBody,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tip aktivnosti "${activityType.name}" je ažuriran.',
                                    ),
                                  ),
                                );
                              } else {
                                await _activityTypeProvider.insert(requestBody);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tip aktivnosti je dodan.'),
                                  ),
                                );
                              }
                              await _fetchActivityTypes();
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
}
