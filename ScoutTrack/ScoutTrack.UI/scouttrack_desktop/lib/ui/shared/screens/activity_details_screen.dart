import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/activity_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_utils.dart';
import 'package:scouttrack_desktop/providers/activity_equipment_provider.dart';
import 'package:scouttrack_desktop/models/activity_equipment.dart';
import 'package:scouttrack_desktop/providers/activity_registration_provider.dart';
import 'package:scouttrack_desktop/models/activity_registration.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen>
    with SingleTickerProviderStateMixin {
  Activity? _activity;
  String? _role;
  int? _loggedInUserId;
  late TabController _tabController;
  List<ActivityEquipment> _equipment = [];
  List<ActivityRegistration> _registrations = [];
  List<ActivityRegistration> _filteredRegistrations = [];
  int? _statusFilter;
  bool _canStartOrFinish = false;
  bool _canManageRegistrations = false;
  late MapController _mapController;
  late ActivityProvider _activityProvider;
  late ActivityRegistrationProvider _activityRegistrationProvider;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  // Pagination variables
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRegistrations = 0;
  bool _isLoadingRegistrations = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mapController = MapController();
    _activity = widget.activity;
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  String _formatActivityState(String state) {
    switch (state) {
      case 'DraftActivityState':
        return 'Nacrt';
      case 'ActiveActivityState':
        return 'Aktivna';
      case 'RegistrationsClosedActivityState':
        return 'Registracije zatvorene';
      case 'FinishedActivityState':
        return 'Završena';
      case 'CancelledActivityState':
        return 'Otkazana';
      default:
        return state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _activityProvider = ActivityProvider(authProvider);
    _activityRegistrationProvider = ActivityRegistrationProvider(authProvider);
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = await authProvider.getUserRole();
    final userId = await authProvider.getUserIdFromToken();

    setState(() {
      _role = role;
      _loggedInUserId = userId;
      _canStartOrFinish =
          role == 'Admin' || (role == 'Troop' && userId == _activity?.troopId);
      _canManageRegistrations =
          role == 'Admin' || (role == 'Troop' && userId == _activity?.troopId);
    });

    await _loadEquipment();
    await _loadRegistrations();
  }

  Future<void> _loadEquipment() async {
    try {
      final activityEquipmentProvider = ActivityEquipmentProvider(
        Provider.of<AuthProvider>(context, listen: false),
      );
      final equipment = await activityEquipmentProvider.getByActivityId(
        _activity!.id,
      );
      setState(() {
        _equipment = equipment;
      });
    } catch (e) {
      print('Error loading equipment: $e');
    }
  }

  Future<void> _loadRegistrations({int? page}) async {
    if (page != null) {
      _currentPage = page;
    }

    setState(() {
      _isLoadingRegistrations = true;
    });

    try {
      final filter = <String, dynamic>{
        'page': _currentPage - 1, // Backend expects 0-based pagination
        'pageSize': _pageSize,
        'includeTotalCount': true,
      };

      // Add status filter if selected
      if (_statusFilter != null) {
        filter['status'] = _statusFilter;
      }

      final registrations = await _activityRegistrationProvider.getByActivity(
        _activity!.id,
        filter: filter,
      );

      print('DEBUG: registrations.items = ${registrations.items}');
      print('DEBUG: registrations.totalCount = ${registrations.totalCount}');
      print(
        'DEBUG: registrations.items?.length = ${registrations.items?.length}',
      );

      setState(() {
        _registrations = registrations.items ?? [];
        _totalRegistrations = registrations.totalCount ?? 0;
        _isLoadingRegistrations = false;
        _applyStatusFilter();
      });

      print(
        'DEBUG: After setState - _registrations.length = ${_registrations.length}',
      );
      print(
        'DEBUG: After setState - _filteredRegistrations.length = ${_filteredRegistrations.length}',
      );
    } catch (e) {
      setState(() {
        _isLoadingRegistrations = false;
      });
      print('Error loading registrations: $e');
    }
  }

  void _applyStatusFilter() {
    // With pagination, filtering is handled server-side
    _filteredRegistrations = List.from(_registrations);
  }

  void _onStatusFilterChanged(int? value) {
    setState(() {
      _statusFilter = value;
      _currentPage = 1; // Reset to first page when filter changes
    });
    _loadRegistrations();
  }

  Widget _buildPaginationControls() {
    final totalPages = (_totalRegistrations / _pageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _currentPage > 1
              ? () => _loadRegistrations(page: _currentPage - 1)
              : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Prethodna'),
        ),
        Row(
          children: [
            if (totalPages <= 7) ...[
              for (int i = 1; i <= totalPages; i++)
                _buildRegistrationPageButton(i, i == _currentPage),
            ] else ...[
              _buildRegistrationPageButton(1, _currentPage == 1),
              if (_currentPage > 3) const Text('...'),
              if (_currentPage > 2)
                _buildRegistrationPageButton(_currentPage - 1, false),
              _buildRegistrationPageButton(_currentPage, true),
              if (_currentPage < totalPages - 1)
                _buildRegistrationPageButton(_currentPage + 1, false),
              if (_currentPage < totalPages - 2) const Text('...'),
              _buildRegistrationPageButton(
                totalPages,
                _currentPage == totalPages,
              ),
            ],
          ],
        ),
        TextButton.icon(
          onPressed: _currentPage < totalPages
              ? () => _loadRegistrations(page: _currentPage + 1)
              : null,
          label: const Text('Sljedeća'),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  Widget _buildRegistrationPageButton(int page, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isActive
            ? const Color(0xFF4F8055)
            : Colors.grey.shade300,
        child: TextButton(
          onPressed: isActive ? null : () => _loadRegistrations(page: page),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? '',
      selectedMenu: 'Aktivnosti',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _activity?.title ?? 'Aktivnost',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 1, child: _buildActivityDetailsPanel()),
                  Expanded(flex: 1, child: _buildRightPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetailsPanel() {
    if (_activity == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity image if exists
            if (_activity!.imagePath.isNotEmpty) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _activity!.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Key information with icons
            UIComponents.buildDetailRow(
              'Odred',
              _activity!.troopName,
              Icons.group,
            ),
            UIComponents.buildDetailRow(
              'Lokacija',
              _activity!.locationName,
              Icons.location_on,
            ),
            UIComponents.buildDetailRow(
              'Datum',
              _activity!.startTime != null && _activity!.endTime != null
                  ? '${DateFormat('dd. MM. yyyy.').format(_activity!.startTime!)} - ${DateFormat('dd. MM. yyyy.').format(_activity!.endTime!)}'
                  : 'Datum nije određen',
              Icons.calendar_today,
            ),
            const SizedBox(height: 24),

            // Location map
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MapUtils.createMapWidget(
                  location: LatLng(_activity!.latitude, _activity!.longitude),
                  mapController: _mapController,
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _activity!.description.isNotEmpty
                        ? _activity!.description
                        : 'Nema opisa aktivnosti.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Summary section (only show for finished activities)
            if (_activity!.activityState == 'FinishedActivityState') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.summarize,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sažetak aktivnosti',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (_canStartOrFinish) ...[
                          const Spacer(),
                          IconButton(
                            onPressed: _onWriteSummary,
                            icon: const Icon(Icons.edit, color: Colors.green),
                            tooltip: 'Uredi sažetak',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _activity!.summary.isNotEmpty
                          ? _activity!.summary
                          : 'Sažetak aktivnosti još nije napisan.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Additional details with icons
            UIComponents.buildDetailSection('Detalji aktivnosti', [
              UIComponents.buildDetailRow(
                'Tip aktivnosti',
                _activity!.activityTypeName,
                Icons.category,
              ),
              UIComponents.buildDetailRow(
                'Kotizacija',
                '${_activity!.fee.toStringAsFixed(2)} KM',
                Icons.payment,
              ),
              UIComponents.buildDetailRow(
                'Broj učesnika',
                _activity!.memberCount.toString(),
                Icons.people,
              ),
              UIComponents.buildDetailRow(
                'Status',
                _formatActivityState(_activity!.activityState),
                Icons.info_outline,
              ),
              UIComponents.buildDetailRow(
                'Privatnost',
                _activity!.isPrivate ? 'Privatan' : 'Javan',
                Icons.visibility,
              ),
              if (_activity!.startTime != null)
                UIComponents.buildDetailRow(
                  'Vrijeme početka',
                  formatDateTime(_activity!.startTime!),
                  Icons.access_time,
                ),
              if (_activity!.endTime != null)
                UIComponents.buildDetailRow(
                  'Vrijeme završetka',
                  formatDateTime(_activity!.endTime!),
                  Icons.access_time_filled,
                ),
            ]),

            const SizedBox(height: 32),

            // Equipment section
            if (_equipment.isNotEmpty) ...[
              UIComponents.buildDetailSection('Preporučena oprema', [
                ..._equipment.map(
                  (eq) => UIComponents.buildDetailRow(
                    eq.equipmentName,
                    '',
                    Icons.backpack,
                  ),
                ),
              ]),
              const SizedBox(height: 32),
            ],

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4F8055),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4F8055),
              tabs: const [
                Tab(text: 'Galerija'),
                Tab(text: 'Registracije'),
                Tab(text: 'Recenzije'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGalleryTab(),
                _buildRegistrationsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Galerija',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Not implemented yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Registracije (${_filteredRegistrations.length}/${_totalRegistrations})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int?>(
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filtriraj po statusu',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Svi statusi'),
                    ),
                    DropdownMenuItem<int>(value: 0, child: Text('Na čekanju')),
                    DropdownMenuItem<int>(value: 1, child: Text('Odobreno')),
                    DropdownMenuItem<int>(value: 2, child: Text('Odbijeno')),
                    DropdownMenuItem<int>(value: 3, child: Text('Završeno')),
                    DropdownMenuItem<int>(value: 4, child: Text('Otkazano')),
                  ],
                  onChanged: _onStatusFilterChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8,
                radius: const Radius.circular(4),
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 800),
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 8,
                      radius: const Radius.circular(4),
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: _isLoadingRegistrations
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : DataTable(
                                headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.grey.shade100,
                                ),
                                columnSpacing: 32,
                                columns: [
                                  const DataColumn(label: Text('UČESNIK')),
                                  const DataColumn(label: Text('NAPOMENA')),
                                  const DataColumn(label: Text('STATUS')),
                                  const DataColumn(
                                    label: Text('VRIJEME REGISTRACIJE'),
                                  ),
                                  if (_canManageRegistrations)
                                    const DataColumn(label: Text('AKCIJE')),
                                ],
                                rows: _filteredRegistrations
                                    .map(
                                      (registration) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              registration.memberName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              registration.notes.isNotEmpty
                                                  ? registration.notes
                                                  : 'Nema napomene',
                                              style: TextStyle(
                                                color:
                                                    registration
                                                        .notes
                                                        .isNotEmpty
                                                    ? Colors.black87
                                                    : Colors.grey,
                                                fontStyle:
                                                    registration.notes.isEmpty
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            _buildRegistrationStatusChip(
                                              registration.status,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              DateFormat(
                                                'dd. MM. yyyy. HH:mm',
                                              ).format(
                                                registration.registeredAt,
                                              ),
                                            ),
                                          ),
                                          if (_canManageRegistrations)
                                            DataCell(
                                              _buildRegistrationActions(
                                                registration,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_filteredRegistrations.isEmpty && !_isLoadingRegistrations) ...[
            const SizedBox(height: 32),
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _statusFilter == null
                  ? 'Nema registracija'
                  : 'Nema registracija s odabranim statusom',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusFilter == null
                  ? 'Još se niko nije prijavio na ovu aktivnost.'
                  : 'Nema registracija s odabranim statusom.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          if (_totalRegistrations > 0) ...[
            const SizedBox(height: 16),
            _buildPaginationControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildRegistrationStatusChip(int status) {
    final statusData = {
      0: {'text': 'Na čekanju', 'color': Colors.orange},
      1: {'text': 'Odobreno', 'color': Colors.green},
      2: {'text': 'Odbijeno', 'color': Colors.red},
      3: {'text': 'Otkazano', 'color': Colors.grey},
      4: {'text': 'Završeno', 'color': Colors.blue},
    };

    final data =
        statusData[status] ?? {'text': 'Nepoznato', 'color': Colors.grey};
    final color = data['color'] as MaterialColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        data['text'] as String,
        style: TextStyle(
          color: color.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRegistrationActions(ActivityRegistration registration) {
    final actions = <Widget>[];

    if (registration.status == 0) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          tooltip: 'Odobri',
          onPressed: () => _onApproveRegistration(registration),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
          tooltip: 'Odbij',
          onPressed: () => _onRejectRegistration(registration),
        ),
      ]);
    } else if (registration.status == 1) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
          tooltip: 'Odbij',
          onPressed: () => _onRejectRegistration(registration),
        ),
        IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue, size: 20),
          tooltip: 'Označi kao završeno',
          onPressed: () => _onCompleteRegistration(registration),
        ),
      ]);
    } else if (registration.status == 2) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          tooltip: 'Odobri',
          onPressed: () => _onApproveRegistration(registration),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  Future<void> _onApproveRegistration(ActivityRegistration registration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odobri registraciju'),
        content: Text(
          'Jeste li sigurni da želite odobriti registraciju za ${registration.memberName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Odobri'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityRegistrationProvider.approve(registration.id);
        await _loadRegistrations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registracija za ${registration.memberName} je odobrena.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onRejectRegistration(ActivityRegistration registration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odbij registraciju'),
        content: Text(
          'Jeste li sigurni da želite odbiti registraciju za ${registration.memberName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Odbij'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityRegistrationProvider.reject(registration.id);
        await _loadRegistrations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registracija za ${registration.memberName} je odbijena.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onCompleteRegistration(
    ActivityRegistration registration,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Označi kao završeno'),
        content: Text(
          'Jeste li sigurni da želite označiti registraciju za ${registration.memberName} kao završenu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Završi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityRegistrationProvider.complete(registration.id);
        await _loadRegistrations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registracija za ${registration.memberName} je označena kao završena.',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Pretraži...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: null,
              hint: const Text('Sortiraj'),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Najnovije')),
                DropdownMenuItem(value: 'oldest', child: Text('Najstarije')),
                DropdownMenuItem(value: 'rating', child: Text('Po ocjeni')),
              ],
              onChanged: (value) {
                // TODO: Implement sorting
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'UČESNIK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'OCJENA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'RECENZIJA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Recenzije',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Not implemented yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back),
              label: const Text('Prethodna'),
            ),
            Row(
              children: [
                _buildPageButton(1, true),
                _buildPageButton(2, false),
                _buildPageButton(3, false),
                const Text('...'),
                _buildPageButton(6, false),
                _buildPageButton(7, false),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text('Sljedeća'),
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Prikazano 10 od 64', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPageButton(int page, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isActive
            ? const Color(0xFF4F8055)
            : Colors.grey.shade300,
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Only show action buttons if user owns the activity or is admin
    if (!_canStartOrFinish) {
      return const SizedBox.shrink();
    }

    // Determine which buttons to show based on activity state
    final activityState = _activity?.activityState ?? '';

    switch (activityState) {
      case 'DraftActivityState':
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _onActivateActivity,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Otvori registracije'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onTogglePrivacy,
              icon: Icon(
                _activity?.isPrivate == true ? Icons.public : Icons.lock,
              ),
              label: Text(
                _activity?.isPrivate == true
                    ? 'Učini javnom'
                    : 'Učini privatnom',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _activity?.isPrivate == true
                    ? Colors.blue
                    : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onCancelActivity,
              icon: const Icon(Icons.cancel),
              label: const Text('Otkaži aktivnost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      case 'ActiveActivityState':
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _onCloseRegistrations,
              icon: const Icon(Icons.lock),
              label: const Text('Zatvori registracije'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onTogglePrivacy,
              icon: Icon(
                _activity?.isPrivate == true ? Icons.public : Icons.lock,
              ),
              label: Text(
                _activity?.isPrivate == true
                    ? 'Učini javnom'
                    : 'Učini privatnom',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _activity?.isPrivate == true
                    ? Colors.blue
                    : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onCancelActivity,
              icon: const Icon(Icons.cancel),
              label: const Text('Otkaži aktivnost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      case 'RegistrationsClosedActivityState':
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _onFinishActivity,
              icon: const Icon(Icons.check_circle),
              label: const Text('Završi aktivnost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onTogglePrivacy,
              icon: Icon(
                _activity?.isPrivate == true ? Icons.public : Icons.lock,
              ),
              label: Text(
                _activity?.isPrivate == true
                    ? 'Učini javnom'
                    : 'Učini privatnom',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _activity?.isPrivate == true
                    ? Colors.blue
                    : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _onCancelActivity,
              icon: const Icon(Icons.cancel),
              label: const Text('Otkaži aktivnost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _onCloseRegistrations() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zatvori registracije'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jeste li sigurni da želite zatvoriti registracije za ovu aktivnost?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Posljedice:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Novi učesnici se neće moći prijaviti'),
            Text('• Aktivnost se ne može više uređivati'),
            Text('• Možete završiti aktivnost kada se održi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Zatvori registracije'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedActivity = await _activityProvider.closeRegistrations(
          _activity!.id,
        );
        setState(() {
          _activity = updatedActivity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registracije su zatvorene. Aktivnost je sada u fazi zatvorenih registracija.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onActivateActivity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otvori registracije'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jeste li sigurni da želite otvoriti registracije za ovu aktivnost?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Posljedice:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Učesnici se mogu prijaviti na aktivnost'),
            Text('• Aktivnost se može uređivati'),
            Text('• Možete zatvoriti registracije kada želite'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Otvori registracije'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedActivity = await _activityProvider.activate(_activity!.id);
        setState(() {
          _activity = updatedActivity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aktivnost je aktivirana. Registracije su sada otvorene.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onFinishActivity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Završi aktivnost'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jeste li sigurni da želite završiti ovu aktivnost?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Posljedice:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Aktivnost se ne može više uređivati'),
            Text('• Učesnici mogu dodavati recenzije i fotografije'),
            Text('• Možete napisati sažetak aktivnosti'),
            Text('• Ova akcija je nepovratna'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Završi aktivnost'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedActivity = await _activityProvider.finish(_activity!.id);
        setState(() {
          _activity = updatedActivity;
        });

        // Refresh registrations after finishing activity
        await _loadRegistrations();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aktivnost je završena. Sada možete dodavati recenzije i fotografije.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _onCancelActivity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkaži aktivnost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jeste li sigurni da želite otkazati aktivnost "${_activity?.title}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Posljedice:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Aktivnost se ne može više uređivati'),
            const Text('• Učesnici neće moći se prijaviti'),
            const Text('• Aktivnost će biti označena kao otkazana'),
            const Text('• Ova akcija je nepovratna'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Otkaži aktivnost'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedActivity = await _activityProvider.deactivate(
          _activity!.id,
        );
        setState(() {
          _activity = updatedActivity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktivnost je otkazana.'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _onWriteSummary() {
    _showSummaryDialog();
  }

  Future<void> _onTogglePrivacy() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _activity?.isPrivate == true ? 'Učini javnom' : 'Učini privatnom',
        ),
        content: Text(
          _activity?.isPrivate == true
              ? 'Jeste li sigurni da želite učiniti ovu aktivnost javnom?'
              : 'Jeste li sigurni da želite učiniti ovu aktivnost privatnom?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _activity?.isPrivate == true
                  ? Colors.blue
                  : Colors.orange,
            ),
            child: Text(
              _activity?.isPrivate == true ? 'Učini javnom' : 'Učini privatnom',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedActivity = await _activityProvider.togglePrivacy(
          _activity!.id,
        );
        setState(() {
          _activity = updatedActivity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _activity?.isPrivate == true
                  ? 'Aktivnost je sada privatna.'
                  : 'Aktivnost je sada javna.',
            ),
            backgroundColor: _activity?.isPrivate == true
                ? Colors.orange
                : Colors.blue,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _showSummaryDialog() async {
    final summaryController = TextEditingController(
      text: _activity?.summary ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Napiši sažetak aktivnosti'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Podijeli svoje iskustvo i utiske sa aktivnosti. Ovo će biti vidljivo svim učesnicima.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: summaryController,
                  decoration: const InputDecoration(
                    labelText: 'Sažetak aktivnosti',
                    hintText: 'Napišite kako je prošla aktivnost...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sažetak je obavezan';
                    }
                    if (value.trim().length > 2000) {
                      return 'Sažetak može imati najviše 2000 karaktera';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final updatedActivity = await _activityProvider
                        .updateSummary(
                          _activity!.id,
                          summaryController.text.trim(),
                        );
                    setState(() {
                      _activity = updatedActivity;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sažetak je sačuvan.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    showErrorSnackbar(context, e);
                  }
                }
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        );
      },
    );
  }
}
