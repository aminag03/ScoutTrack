import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/category.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/category_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/pdf_report_utils.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  SearchResult<Category>? _categories;
  bool _loading = false;
  String? _error;
  String? _role;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late CategoryProvider _categoryProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;
  String? _selectedSort;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _categoryProvider = CategoryProvider(authProvider);
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

    if (mounted) {
      setState(() {
        _role = role;
      });
    }

    if (role == 'Admin') {
      await _fetchCategories();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          currentPage = 1;
        });
        _fetchCategories();
      }
    });
  }

  Future<void> _fetchCategories({int? page}) async {
    if (_loading) return;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      var filter = {
        if (searchController.text.isNotEmpty) "Name": searchController.text,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
        if (_selectedSort != null) "OrderBy": _selectedSort,
      };

      var result = await _categoryProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _categories = result;
          currentPage = page ?? currentPage;
          totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
          if (totalPages == 0) totalPages = 1;
          if (currentPage > totalPages) currentPage = totalPages;
          if (currentPage < 1) currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _categories = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _generateReport() async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
        });
      }

      var filter = {"RetrieveAll": true, "IncludeTotalCount": true};

      var result = await _categoryProvider.get(filter: filter);

      if (result.items != null && result.items!.isNotEmpty) {
        final filePath = await PdfReportUtils.generateCategoryReport(
          result.items!,
          filters: filter,
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
      selectedMenu: 'Kategorije',
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
                      hintText: 'Pretraži kategorije...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String?>(
                      value: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Sortiraj',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                          currentPage = 1;
                        });
                        _fetchCategories();
                      },
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Bez sortiranja'),
                        ),
                        DropdownMenuItem(
                          value: 'Name',
                          child: Text('Naziv (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-Name',
                          child: Text('Naziv (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'MinAge',
                          child: Text('Minimalna starost (rastuće)'),
                        ),
                        DropdownMenuItem(
                          value: '-MinAge',
                          child: Text('Minimalna starost (opadajuće)'),
                        ),
                        DropdownMenuItem(
                          value: 'MaxAge',
                          child: Text('Maksimalna starost (rastuće)'),
                        ),
                        DropdownMenuItem(
                          value: '-MaxAge',
                          child: Text('Maksimalna starost (opadajuće)'),
                        ),
                      ],
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
                  onPressed: _onAddCategory,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Dodaj novu kategoriju',
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
            if (_categories != null)
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
                      'Prikazano ${_categories!.items?.length ?? 0} od ukupno ${_categories!.totalCount ?? 0} kategorija',
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
                totalCount: _categories?.totalCount ?? 0,
                onPageChanged: (page) => _fetchCategories(page: page),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_loading || _categories == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Greška pri učitavanju: $_error',
                style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories!.items == null || _categories!.items!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nema dostupnih kategorija',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
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
                constraints: const BoxConstraints(minWidth: 1000),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade100,
                  ),
                  columnSpacing: 32,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
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
                        child: Text('MINIMALNA STAROST'),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('MAKSIMALNA STAROST'),
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
                        child: Text('VRIJEME IZMJENE'),
                      ),
                    ),
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('')),
                  ],
                  rows: _categories!.items!.map((category) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${category.minAge} godina',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${category.maxAge} godina',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              category.description.isNotEmpty
                                  ? category.description
                                  : '-',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              category.updatedAt != null
                                  ? formatDateTime(category.updatedAt!)
                                  : formatDateTime(category.createdAt),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Uredi',
                            onPressed: () => _onEditCategory(category),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Obriši',
                            onPressed: () => _onDeleteCategory(category),
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

  void _onAddCategory() {
    _showCategoryDialog();
  }

  void _onEditCategory(Category category) {
    _showCategoryDialog(category: category);
  }

  Future<void> _onDeleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati kategoriju ${category.name}?',
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
        await _categoryProvider.delete(category.id);

        final currentItemsOnPage = _categories?.items?.length ?? 0;

        if (currentItemsOnPage == 1 && currentPage > 1) {
          await _fetchCategories(page: currentPage - 1);
        } else {
          await _fetchCategories();
        }

        showSuccessSnackbar(
          context,
          'Kategorija ${category.name} je obrisana.',
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: category?.name ?? '',
    );
    final TextEditingController minAgeController = TextEditingController(
      text: category?.minAge.toString() ?? '',
    );
    final TextEditingController maxAgeController = TextEditingController(
      text: category?.maxAge.toString() ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: category?.description ?? '',
    );

    final isEdit = category != null;

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
                      Text(
                        isEdit ? 'Uredi kategoriju' : 'Dodaj kategoriju',
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
                                labelText: 'Naziv kategorije *',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Naziv je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'Naziv ne smije imati više od 100 znakova.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: minAgeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Minimalna starost *',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Minimalna starost je obavezna.';
                                      }
                                      final age = int.tryParse(value);
                                      if (age == null || age < 0 || age > 100) {
                                        return 'Unesite validnu starost (0-100).';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: maxAgeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Maksimalna starost *',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Maksimalna starost je obavezna.';
                                      }
                                      final age = int.tryParse(value);
                                      if (age == null || age < 0 || age > 100) {
                                        return 'Unesite valjanu starost (0-100).';
                                      }
                                      final minAge = int.tryParse(
                                        minAgeController.text,
                                      );
                                      if (minAge != null && age < minAge) {
                                        return 'Maksimalna starost mora biti veća od minimalne.';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Opis',
                              ),
                              maxLines: 3,
                              maxLength: 500,
                              validator: (value) {
                                if (value != null && value.length > 500) {
                                  return 'Opis ne smije imati više od 500 znakova.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                    "minAge": int.parse(
                                      minAgeController.text.trim(),
                                    ),
                                    "maxAge": int.parse(
                                      maxAgeController.text.trim(),
                                    ),
                                    "description": descriptionController.text
                                        .trim(),
                                  };

                                  if (isEdit) {
                                    await _categoryProvider.update(
                                      category.id,
                                      requestBody,
                                    );
                                    showSuccessSnackbar(
                                      context,
                                      'Kategorija "${category.name}" je ažurirana.',
                                    );
                                    await _fetchCategories(page: currentPage);
                                  } else {
                                    await _categoryProvider.insert(requestBody);
                                    showSuccessSnackbar(
                                      context,
                                      'Kategorija je dodana.',
                                    );
                                    final newTotalCount =
                                        (_categories?.totalCount ?? 0) + 1;
                                    final newTotalPages =
                                        (newTotalCount / pageSize).ceil();
                                    await _fetchCategories(page: newTotalPages);
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
