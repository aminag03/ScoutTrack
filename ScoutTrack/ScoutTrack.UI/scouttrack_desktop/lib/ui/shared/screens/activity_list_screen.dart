import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/models/activity_type.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/activity_provider.dart';
import 'package:scouttrack_desktop/providers/activity_type_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/equipment_provider.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/providers/activity_equipment_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/date_picker_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/activity_form_widgets.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/activity_dialog_widgets.dart';
import 'package:scouttrack_desktop/ui/shared/screens/activity_details_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class ActivityListScreen extends StatefulWidget {
  final int? initialTroopId;

  const ActivityListScreen({super.key, this.initialTroopId});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  SearchResult<Activity>? _activities;
  bool _loading = false;
  String? _error;
  String? _role;
  int? _loggedInUserId;
  final ScrollController _scrollController = ScrollController();
  int? _selectedTroopId;
  int? _selectedActivityTypeId;
  String? _selectedSort;
  bool _showOnlyMyActivities = false;
  List<ActivityType> _activityTypes = [];
  List<Troop> _troops = [];
  List<Equipment> _equipment = [];

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late ActivityProvider _activityProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _activityProvider = ActivityProvider(authProvider);
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
    final userId = await authProvider.getUserIdFromToken();

    setState(() {
      _role = role;
      _loggedInUserId = userId;
    });

    final activityTypeProvider = ActivityTypeProvider(authProvider);
    final troopProvider = TroopProvider(authProvider);
    final equipmentProvider = EquipmentProvider(authProvider);
    var filter = {"RetrieveAll": true};
    final activityTypeResult = await activityTypeProvider.get(filter: filter);
    final troopResult = await troopProvider.get(filter: filter);
    final equipmentResult = await equipmentProvider.get(filter: filter);
    setState(() {
      _activityTypes = activityTypeResult.items ?? [];
      _troops = troopResult.items ?? [];
      _equipment = equipmentResult.items ?? [];

      if (widget.initialTroopId != null) {
        final troopExists = _troops.any(
          (troop) => troop.id == widget.initialTroopId,
        );
        if (troopExists) {
          _selectedTroopId = widget.initialTroopId;
          _showOnlyMyActivities = false;
        }
      }
    });
    await _fetchActivities();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
      });
      _fetchActivities();
    });
  }

  Future<void> _fetchActivities({int? page}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      int? troopIdForFilter = _selectedTroopId;
      if (_showOnlyMyActivities &&
          _role == 'Troop' &&
          _loggedInUserId != null) {
        troopIdForFilter = _loggedInUserId;
      }

      var filter = {
        if (searchController.text.isNotEmpty) "FTS": searchController.text,
        if (troopIdForFilter != null) "TroopId": troopIdForFilter,
        if (_selectedActivityTypeId != null)
          "ActivityTypeId": _selectedActivityTypeId,
        if (_selectedSort != null) "OrderBy": _selectedSort,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };

      if (_role == 'Troop' && _loggedInUserId != null) {
        if (troopIdForFilter == null) {
          filter["ShowPublicAndOwn"] = true;
          filter["OwnTroopId"] = _loggedInUserId;
        }
      }

      var result = await _activityProvider.get(filter: filter);

      setState(() {
        _activities = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _activities = null;
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
      selectedMenu: 'Aktivnosti',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                Expanded(flex: 2, child: _buildTroopDropdown()),
                Expanded(flex: 2, child: _buildActivityTypeDropdown()),
                Expanded(flex: 2, child: _buildSortDropdown()),
                if (_role == 'Admin' || _role == 'Troop')
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton.icon(
                      onPressed: _onAddActivity,
                      icon: const Icon(Icons.add),
                      label: const Text('Kreiraj aktivnost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), minimumSize: const Size(0, 48)),
                    ),
                  ),
              ],
            ),
            if (_role == 'Troop') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _showOnlyMyActivities,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMyActivities = value ?? false;
                        if (_showOnlyMyActivities) {
                          _selectedTroopId = _loggedInUserId;
                        } else {
                          _selectedTroopId = null;
                        }
                        currentPage = 1;
                      });
                      _fetchActivities();
                    },
                  ),
                  const Text(
                    'Prikaži samo moje aktivnosti',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildResultView()),
                  const SizedBox(height: 4),
                  PaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalCount: _activities?.totalCount ?? 0,
                    onPageChanged: (page) => _fetchActivities(page: page),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddActivity() {
    _showActivityDialog();
  }

  void _onEditActivity(Activity activity) {
    _showActivityDialog(activity: activity);
  }

  Future<void> _onDeleteActivity(Activity activity) async {
    final confirm = await UIComponents.showDeleteConfirmationDialog(
      context: context,
      itemName: activity.title,
      itemType: 'aktivnost',
    );
    if (confirm) {
      try {
        await _activityProvider.delete(activity.id);

        final currentItemsOnPage = _activities?.items?.length ?? 0;
        final newTotalCount = (_activities?.totalCount ?? 0) - 1;
        final newTotalPages = (newTotalCount / pageSize).ceil();

        if (currentItemsOnPage == 1 && currentPage > 1) {
          await _fetchActivities(page: currentPage - 1);
        } else {
          await _fetchActivities();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aktivnost "${activity.title}" je obrisana.')),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _onViewActivity(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityDetailsScreen(activity: activity),
      ),
    );
  }

  Future<void> _showActivityDialog({Activity? activity}) async {
    final isEdit = activity != null;
    final _formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController(
      text: activity?.title ?? '',
    );
    final TextEditingController locationNameController = TextEditingController(
      text: activity?.locationName ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: activity?.description ?? '',
    );
    final TextEditingController feeController = TextEditingController(
      text: activity?.fee.toString() ?? '0',
    );
    final TextEditingController startDateController = TextEditingController(
      text: activity?.startTime != null
          ? DateFormat('dd/MM/yyyy').format(activity!.startTime!)
          : DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    final TextEditingController startTimeController = TextEditingController(
      text: activity?.startTime != null
          ? DateFormat('HH:mm').format(activity!.startTime!)
          : '09:00',
    );
    final TextEditingController endDateController = TextEditingController(
      text: activity?.endTime != null
          ? DateFormat('dd/MM/yyyy').format(activity!.endTime!)
          : DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    final TextEditingController endTimeController = TextEditingController(
      text: activity?.endTime != null
          ? DateFormat('HH:mm').format(activity!.endTime!)
          : '09:00',
    );

    int? selectedActivityTypeId = activity?.activityTypeId;
    int? selectedTroopId =
        activity?.troopId ?? (_role == 'Troop' ? _loggedInUserId : null);
    bool isPrivate = activity?.isPrivate ?? false;
    LatLng selectedLocation = LatLng(
      activity?.latitude ?? 43.8564, // Default to Sarajevo
      activity?.longitude ?? 18.4131,
    );

    List<String> equipmentList = [];
    List<TextEditingController> equipmentControllers = [];
    List<Equipment?> selectedEquipment = [];
    Set<int> newlyAddedEquipmentIds =
        {}; // Track newly added equipment for highlighting

    if (isEdit && activity != null) {
      try {
        final activityEquipmentProvider = ActivityEquipmentProvider(
          Provider.of<AuthProvider>(context, listen: false),
        );
        final existingActivityEquipment = await activityEquipmentProvider
            .getByActivityId(activity!.id);

        for (final ae in existingActivityEquipment) {
          final equipment = _equipment.firstWhere(
            (e) => e.id == ae.equipmentId,
            orElse: () => Equipment(
              id: ae.equipmentId,
              name: ae.equipmentName,
              description: ae.equipmentDescription,
              isGlobal: true,
              createdAt: ae.createdAt,
            ),
          );

          equipmentList.add(equipment.name);
          selectedEquipment.add(equipment);
          equipmentControllers.add(TextEditingController(text: equipment.name));
        }
      } catch (e) {
        print('Error loading existing equipment: $e');
      }
    }

    Uint8List? _selectedImageBytes;
    File? _selectedImageFile;
    String? _imagePath = activity?.imagePath;

    Future<void> _selectStartDate(StateSetter setState) async {
      final DateTime? picked = await DatePickerUtils.showDatePickerDialog(
        context: context,
        initialDate: activity?.startTime ?? DateTime.now(),
        minDate: DateTime.now(),
        maxDate: DateTime.now().add(const Duration(days: 365)),
        title: 'Odaberite datum početka',
        controller: startDateController,
      );
      if (picked != null) {
        setState(() {
          startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    }

    Future<void> _selectStartTime(StateSetter setState) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: activity?.startTime != null
            ? TimeOfDay.fromDateTime(activity!.startTime!)
            : const TimeOfDay(hour: 9, minute: 0),
      );
      if (picked != null) {
        setState(() {
          startTimeController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        });
      }
    }

    Future<void> _selectEndDate(StateSetter setState) async {
      final DateTime? picked = await DatePickerUtils.showDatePickerDialog(
        context: context,
        initialDate: activity?.endTime ?? DateTime.now(),
        minDate: DateTime.now(),
        maxDate: DateTime.now().add(const Duration(days: 365)),
        title: 'Odaberite datum završetka',
        controller: endDateController,
      );
      if (picked != null) {
        setState(() {
          endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    }

    Future<void> _selectEndTime(StateSetter setState) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: activity?.endTime != null
            ? TimeOfDay.fromDateTime(activity!.endTime!)
            : const TimeOfDay(hour: 9, minute: 0),
      );
      if (picked != null) {
        setState(() {
          endTimeController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        });
      }
    }

    Future<void> _selectLocation(StateSetter setState) async {
      final result = await MapUtils.showMapPickerDialog(
        context: context,
        initialLocation: selectedLocation,
        title: 'Odaberite lokaciju aktivnosti',
      );
      if (result != null) {
        setState(() {
          selectedLocation = result;
        });
      }
    }

    Future<void> _pickImage(StateSetter setState) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final compressedBytes = await ImageUtils.compressImage(bytes);
        setState(() {
          _selectedImageBytes = compressedBytes;
          _selectedImageFile = File(pickedFile.path);
        });
      }
    }

    Future<Equipment?> _showAddNewEquipmentDialog() async {
      return await ActivityDialogWidgets.showAddNewEquipmentDialog(
        context: context,
        onEquipmentAdded: (equipment) async {
          final equipmentProvider = EquipmentProvider(
            Provider.of<AuthProvider>(context, listen: false),
          );

          final newEquipment = await equipmentProvider.insert({
            "name": equipment.name,
            "description": equipment.description,
            "isGlobal": false,
          });

          setState(() {
            _equipment.add(newEquipment);
            newlyAddedEquipmentIds.add(newEquipment.id);
          });
          return newEquipment;
        },
      );
    }

    Future<dynamic> _showEquipmentSelectionDialog() async {
      return await ActivityDialogWidgets.showEquipmentSelectionDialog(
        context: context,
        equipment: _equipment,
        onAddNewEquipment: () async {
          final newEquipment = await _showAddNewEquipmentDialog();
          if (newEquipment != null) {
            return newEquipment;
          }
          return null;
        },
      );
    }

    Future<void> _addEquipmentItem(StateSetter setState) async {
      final result = await _showEquipmentSelectionDialog();
      print(
        '_addEquipmentItem received result: ${result?.runtimeType} - ${result?.toString()}',
      );
      if (result is Equipment) {
        final alreadySelected = selectedEquipment.any(
          (eq) => eq?.id == result.id,
        );
        if (!alreadySelected) {
          print('Adding equipment to selectedEquipment list: ${result.name}');
          setState(() {
            equipmentList.add(result.name);
            selectedEquipment.add(result);
            equipmentControllers.add(TextEditingController(text: result.name));
            newlyAddedEquipmentIds.add(result.id);
          });

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                newlyAddedEquipmentIds.remove(result.id);
              });
            }
          });
        } else {
          print('Equipment already selected: ${result.name}');
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Oprema već dodana'),
              content: Text('Oprema "${result.name}" je već dodana u listu.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('U redu'),
                ),
              ],
            ),
          );
        }
      }
    }

    void _removeEquipmentItem(StateSetter setState, int index) {
      setState(() {
        equipmentList.removeAt(index);
        selectedEquipment.removeAt(index);
        equipmentControllers[index].dispose();
        equipmentControllers.removeAt(index);
      });
    }

    void _updateEquipmentItem(StateSetter setState, int index, String value) {
      setState(() => equipmentList[index] = value);
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
                  maxWidth: 1000,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? 'Uredi aktivnost' : 'Kreiraj aktivnost',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* Obavezna polja',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 250,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _selectedImageBytes != null
                                            ? Image.memory(
                                                _selectedImageBytes!,
                                                fit: BoxFit.cover,
                                              )
                                            : (_imagePath != null &&
                                                      _imagePath!.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        _imagePath!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return const Center(
                                                                child: Icon(
                                                                  Icons.image,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .add_photo_alternate,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Dodajte naslovnu fotografiju',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                      ),
                                    ),
                                    if (_imagePath != null &&
                                            _imagePath!.isNotEmpty ||
                                        _selectedImageBytes != null)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final shouldDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Obriši fotografiju',
                                                ),
                                                content: const Text(
                                                  'Da li ste sigurni da želite obrisati ovu fotografiju?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('Otkaži'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
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

                                            if (shouldDelete == true) {
                                              setState(() {
                                                _selectedImageBytes = null;
                                                _selectedImageFile = null;
                                                _imagePath = null;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
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
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(setState),
                                  icon: const Icon(Icons.image, size: 16),
                                  label: const Text('Dodaj fotografiju'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Preporučena oprema',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _addEquipmentItem(setState),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Dodaj stavku'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement AI suggestion
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'AI prijedlog će biti implementiran',
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.auto_awesome,
                                          size: 16,
                                        ),
                                        label: const Text('AI prijedlog'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                ...equipmentList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final equipment = selectedEquipment[index];
                                  return ActivityFormWidgets.buildEquipmentItem(
                                    index: index,
                                    item: entry.value,
                                    equipment: equipment,
                                    controller: equipmentControllers[index],
                                    onUpdate: _updateEquipmentItem,
                                    onRemove: _removeEquipmentItem,
                                    setState: setState,
                                    isNewlyAdded:
                                        equipment != null &&
                                        newlyAddedEquipmentIds.contains(
                                          equipment.id,
                                        ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Upišite naziv aktivnosti *',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
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
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: locationNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Upišite naziv lokacije *',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Naziv lokacije je obavezan.';
                                      }
                                      if (value.length > 200) {
                                        return 'Naziv lokacije ne smije imati više od 200 znakova.';
                                      }
                                      final regex = RegExp(
                                        r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$",
                                      );
                                      if (!regex.hasMatch(value.trim())) {
                                        return 'Naziv lokacije može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => _selectLocation(setState),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Odaberite lokaciju održavanja',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  MapUtils.formatCoordinates(
                                                    selectedLocation,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.edit,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectStartDate(setState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: startDateController,
                                              decoration: const InputDecoration(
                                                labelText: 'Datum početka *',
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 3,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Datum početka je obavezan';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectStartTime(setState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: startTimeController,
                                              decoration: const InputDecoration(
                                                labelText: 'Vrijeme početka *',
                                                suffixIcon: Icon(
                                                  Icons.access_time,
                                                ),
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 3,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Vrijeme početka je obavezno';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _selectEndDate(setState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: endDateController,
                                              decoration: const InputDecoration(
                                                labelText: 'Datum završetka *',
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 3,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Datum završetka je obavezan';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _selectEndTime(setState),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: endTimeController,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Vrijeme završetka *',
                                                suffixIcon: Icon(
                                                  Icons.access_time,
                                                ),
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 3,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Vrijeme završetka je obavezno';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Kratak opis aktivnosti',
                                      hintText: 'Napišite nešto...',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value != null && value.length > 500) {
                                        return 'Opis ne smije imati više od 500 znakova.';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: feeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Kotizacija',
                                      suffixText: 'KM',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final fee = double.tryParse(value);
                                        if (fee == null || fee < 0) {
                                          return 'Naknada mora biti pozitivan broj';
                                        }
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<String>(
                                    value: isPrivate ? 'Privatan' : 'Javan',
                                    decoration: const InputDecoration(
                                      labelText: 'Vidljivost događaja',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Javan',
                                        child: Text('Javan'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Privatan',
                                        child: Text('Privatan'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        isPrivate = value == 'Privatan';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<int>(
                                    value: selectedActivityTypeId,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Odaberite osnovni tip aktivnosti *',
                                      border: OutlineInputBorder(),
                                      errorMaxLines: 3,
                                    ),
                                    items: _activityTypes
                                        .map(
                                          (type) => DropdownMenuItem<int>(
                                            value: type.id,
                                            child: Text(type.name),
                                          ),
                                        )
                                        .toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Tip aktivnosti je obavezan.';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedActivityTypeId = val;
                                      });
                                    },
                                  ),

                                  if (_role == 'Admin' && !isEdit) ...[
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<int>(
                                      value: selectedTroopId,
                                      decoration: const InputDecoration(
                                        labelText: 'Odred *',
                                        border: OutlineInputBorder(),
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
                                      onChanged: (val) {
                                        setState(() {
                                          selectedTroopId = val;
                                        });
                                      },
                                    ),
                                  ],

                                  if (_role == 'Troop' && !isEdit) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.group,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Odred: ${_getTroopName(_loggedInUserId)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
                                  final startDateTime = _parseDateTime(
                                    startDateController.text,
                                    startTimeController.text,
                                  );
                                  final endDateTime = _parseDateTime(
                                    endDateController.text,
                                    endTimeController.text,
                                  );

                                  final now = DateTime.now();
                                  final nowRounded = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    now.hour,
                                    now.minute,
                                  );
                                  if (startDateTime.isBefore(nowRounded)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Vrijeme početka ne može biti u prošlosti.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (endDateTime.isBefore(startDateTime)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Vrijeme završetka mora biti nakon vremena početka.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final requestBody = {
                                    "title": titleController.text.trim(),
                                    "locationName": locationNameController.text
                                        .trim(),
                                    "description": descriptionController.text
                                        .trim(),
                                    "isPrivate": isPrivate,
                                    "locationName": locationNameController.text
                                        .trim(),
                                    "latitude": selectedLocation.latitude,
                                    "longitude": selectedLocation.longitude,
                                    "fee":
                                        double.tryParse(feeController.text) ??
                                        0.0,
                                    "startTime": startDateTime
                                        .toIso8601String(),
                                    "endTime": endDateTime.toIso8601String(),
                                    "activityTypeId": selectedActivityTypeId,
                                    "troopId": _role == 'Admin'
                                        ? selectedTroopId
                                        : _loggedInUserId,
                                    if (_imagePath != null &&
                                        _imagePath!.isNotEmpty)
                                      "imagePath": _imagePath,
                                  };
                                  if (isEdit) {
                                    if (_selectedImageFile != null) {
                                      await _activityProvider.update(
                                        activity!.id,
                                        requestBody,
                                      );
                                      await _activityProvider.updateImage(
                                        activity!.id,
                                        _selectedImageFile,
                                      );
                                    } else if (activity!.imagePath != null &&
                                        activity.imagePath!.isNotEmpty &&
                                        _imagePath == null) {
                                      await _activityProvider.updateImage(
                                        activity!.id,
                                        null,
                                      );
                                      await _activityProvider.update(
                                        activity!.id,
                                        requestBody,
                                      );
                                    }

                                    await _saveActivityEquipment(
                                      activity!.id,
                                      selectedEquipment,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Aktivnost "${titleController.text}" je ažurirana.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    final newActivity = await _activityProvider
                                        .insert(requestBody);

                                    if (_selectedImageFile != null) {
                                      await _activityProvider.updateImage(
                                        newActivity.id,
                                        _selectedImageFile,
                                      );
                                    }

                                    await _saveActivityEquipment(
                                      newActivity.id,
                                      selectedEquipment,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Aktivnost je dodana.'),
                                      ),
                                    );
                                  }
                                  final newTotalCount =
                                      (_activities?.totalCount ?? 0) + 1;
                                  final newTotalPages =
                                      (newTotalCount / pageSize).ceil();
                                  await _fetchActivities(page: newTotalPages);
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  showErrorSnackbar(context, e);
                                }
                              }
                            },
                            child: Text(
                              isEdit ? 'Sačuvaj' : 'Kreiraj aktivnost',
                            ),
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

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) {
        throw FormatException('Invalid date format: $dateStr');
      }

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final timeParts = timeStr.split(':');
      int hour = 0;
      int minute = 0;

      if (timeStr.isNotEmpty && timeParts.length == 2) {
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException(
        'Failed to parse date/time: $dateStr $timeStr - ${e.toString()}',
      );
    }
  }

  String _getTroopName(int? troopId) {
          if (troopId == null) return 'Nepoznat odred';
      try {
        return _troops.firstWhere((t) => t.id == troopId, orElse: () => Troop(name: 'Nepoznat odred', createdAt: DateTime.now(), foundingDate: DateTime.now())).name;
      } catch (e) {
        return 'Nepoznat odred';
      }
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Pretraži aktivnosti...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTroopDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
              child: DropdownButtonFormField<int?>(
          value: _selectedTroopId,
          decoration: const InputDecoration(labelText: 'Odred', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedTroopId = value;
              if (value != null) _showOnlyMyActivities = false;
              currentPage = 1;
            });
            _fetchActivities();
          },
          items: [
            const DropdownMenuItem(value: null, child: Text("Svi odredi")),
            ..._troops.map((troop) => DropdownMenuItem(value: troop.id, child: Text(troop.name))),
          ],
        ),
    );
  }

  Widget _buildActivityTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
              child: DropdownButtonFormField<int?>(
          value: _selectedActivityTypeId,
          decoration: const InputDecoration(labelText: 'Tip aktivnosti', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedActivityTypeId = value;
              currentPage = 1;
            });
            _fetchActivities();
          },
          items: [
            const DropdownMenuItem(value: null, child: Text("Svi tipovi")),
            ..._activityTypes.map((type) => DropdownMenuItem(value: type.id, child: Text(type.name))),
          ],
        ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
              child: DropdownButtonFormField<String?>(
          value: _selectedSort,
          decoration: const InputDecoration(labelText: 'Sortiraj', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedSort = value;
              currentPage = 1;
            });
            _fetchActivities();
          },
          items: const [
            DropdownMenuItem(value: null, child: Text('Bez sortiranja')),
            DropdownMenuItem(value: 'title', child: Text('Naziv (A-Ž)')),
            DropdownMenuItem(value: '-title', child: Text('Naziv (Ž-A)')),
            DropdownMenuItem(value: 'startTime', child: Text('Vrijeme početka (najranije)')),
            DropdownMenuItem(value: '-startTime', child: Text('Vrijeme početka (najkasnije)')),
            DropdownMenuItem(value: 'endTime', child: Text('Vrijeme završetka (najranije)')),
            DropdownMenuItem(value: '-endTime', child: Text('Vrijeme završetka (najkasnije)')),
            DropdownMenuItem(value: 'memberCount', child: Text('Broj učesnika (najmanji)')),
            DropdownMenuItem(value: '-memberCount', child: Text('Broj učesnika (najveći)')),
          ],
        ),
    );
  }

  bool _canEditOrDeleteActivity(Activity activity) {
    return _role == 'Admin' ||
        (_role == 'Troop' && _loggedInUserId == activity.troopId);
  }

  bool _canEditActivity(Activity activity) {
    final canEditOrDelete = _canEditOrDeleteActivity(activity);

    if (!canEditOrDelete) return false;

    return activity.activityState == 'DraftActivityState';
  }

  String _getEditDisabledReason(Activity activity) {
    final canEditOrDelete =
        _role == 'Admin' ||
        (_role == 'Troop' && _loggedInUserId == activity.troopId);

    if (!canEditOrDelete) {
      return 'Nemate dozvolu za uređivanje ove aktivnosti';
    }

    switch (activity.activityState) {
      case 'ActiveActivityState':
        return 'Aktivnost je aktivna i ne može se uređivati';
      case 'RegistrationsClosedActivityState':
        return 'Prijave su zatvorene, aktivnost se ne može uređivati';
      case 'FinishedActivityState':
        return 'Aktivnost je završena, ne može se uređivati';
      case 'CancelledActivityState':
        return 'Aktivnost je otkazana, ne može se uređivati';
      case 'DraftActivityState':
        return 'Aktivnost se može uređivati';
      default:
        return 'Aktivnost se ne može uređivati';
    }
  }

  bool _canDeleteActivity(Activity activity) {
    final canEditOrDelete =
        _role == 'Admin' ||
        (_role == 'Troop' && _loggedInUserId == activity.troopId);

    if (!canEditOrDelete) return false;

    return true;
  }

  String _getDeleteDisabledReason(Activity activity) {
    final canEditOrDelete =
        _role == 'Admin' ||
        (_role == 'Troop' && _loggedInUserId == activity.troopId);

    if (!canEditOrDelete) {
      return 'Nemate dozvolu za brisanje ove aktivnosti';
    }

    return 'Aktivnost se može brisati';
  }

      Widget _buildActivityStateChip(String activityState) {
      final stateConfig = {
        'DraftActivityState': {'text': 'Nacrt', 'color': Colors.grey.shade300, 'textColor': Colors.black},
        'ActiveActivityState': {'text': 'Aktivna', 'color': Colors.green.shade100, 'textColor': Colors.green},
        'RegistrationsClosedActivityState': {'text': 'Prijave zatvorene', 'color': Colors.orange.shade100, 'textColor': Colors.orange},
        'FinishedActivityState': {'text': 'Završena', 'color': Colors.blue.shade100, 'textColor': Colors.blue},
        'CancelledActivityState': {'text': 'Otkazana', 'color': Colors.red.shade100, 'textColor': Colors.red},
      };

      final config = stateConfig[activityState] ?? {'text': activityState, 'color': Colors.grey.shade100, 'textColor': Colors.grey.shade600};

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: config['color'] as Color, borderRadius: BorderRadius.circular(12)),
        child: Text(config['text'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: config['textColor'] as Color)),
      );
    }

  Future<void> _saveActivityEquipment(
    int activityId,
    List<Equipment?> selectedEquipment,
  ) async {
    try {
      final activityEquipmentProvider = ActivityEquipmentProvider(
        Provider.of<AuthProvider>(context, listen: false),
      );

      final existingEquipment = await activityEquipmentProvider.getByActivityId(
        activityId,
      );

      for (final existing in existingEquipment) {
        final stillSelected = selectedEquipment.any(
          (eq) => eq?.id == existing.equipmentId,
        );
        if (!stillSelected) {
          await activityEquipmentProvider.removeByActivityIdAndEquipmentId(
            activityId,
            existing.equipmentId,
          );
        }
      }

      for (final equipment in selectedEquipment) {
        if (equipment != null) {
          final alreadyExists = existingEquipment.any(
            (eq) => eq.equipmentId == equipment.id,
          );
          if (!alreadyExists) {
            await activityEquipmentProvider.insert({
              "activityId": activityId,
              "equipmentId": equipment.id,
            });
          }
        }
      }
    } catch (e) {
      print('Error saving activity equipment: $e');
    }
  }

  Widget _buildResultView() {
    if (_loading && _activities == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Greška pri učitavanju: $_error', style: const TextStyle(color: Colors.red)));
    }
    if (_activities?.items?.isEmpty ?? true) {
      return const Center(child: Text('Nema dostupnih aktivnosti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
    }

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1200),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
                          child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade100),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('NAZIV'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('LOKACIJA'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('VRIJEME POČETKA'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('VRIJEME ZAVRŠETKA'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('ODRED'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('TIP'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('PRIVATNOST'))),
                DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('STATUS'))),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: _activities!.items!.map((activity) => _buildActivityRow(activity)).toList(),
            ),
            ),
          ),
        ),
      ),
    );
  }

    DataRow _buildActivityRow(Activity activity) {
    return DataRow(
      cells: [
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.title))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.locationName))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.startTime != null ? formatDateTime(activity.startTime!) : '-'))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.endTime != null ? formatDateTime(activity.endTime!) : '-'))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.troopName))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(activity.activityTypeName))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: activity.isPrivate ? const Icon(Icons.lock, color: Colors.red, size: 16) : const Icon(Icons.public, color: Colors.green, size: 16))),
        DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _buildActivityStateChip(activity.activityState))),
        DataCell(IconButton(icon: const Icon(Icons.visibility, color: Colors.grey), tooltip: 'Prikaži detalje', onPressed: () => _onViewActivity(activity))),
        DataCell(_canEditOrDeleteActivity(activity) ? (_canEditActivity(activity) ? IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Uredi', onPressed: () => _onEditActivity(activity)) : IconButton(icon: const Icon(Icons.edit, color: Colors.grey), tooltip: _getEditDisabledReason(activity), onPressed: null)) : const SizedBox()),
        DataCell(_canEditOrDeleteActivity(activity) ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Obriši', onPressed: () => _onDeleteActivity(activity)) : const SizedBox()),
      ],
    );
  }
}
