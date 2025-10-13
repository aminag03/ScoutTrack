import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/activity_type_provider.dart';
import '../providers/troop_provider.dart';
import '../providers/activity_registration_provider.dart';
import '../providers/member_provider.dart';
import '../models/activity.dart';
import '../models/activity_type.dart';
import '../models/activity_registration.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'activity_details_screen.dart';
import 'activity_registration_screen.dart';

class ActivityListScreen extends StatefulWidget {
  final int? memberId;
  final int? troopId;
  final String title;
  final bool showMyRegistrations;
  final bool showMemberActivities;
  final String? memberName;
  final bool showAllAvailableActivities;

  const ActivityListScreen({
    super.key,
    this.memberId,
    this.troopId,
    required this.title,
    this.showMyRegistrations = false,
    this.showMemberActivities = false,
    this.memberName,
    this.showAllAvailableActivities = false,
  });

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<Activity> _allActivities = [];
  List<Activity> _filteredActivities = [];
  List<ActivityRegistration> _allRegistrations = [];
  List<ActivityRegistration> _filteredRegistrations = [];
  List<ActivityType> _activityTypes = [];
  List<String> _allTroops = [];
  bool _isLoading = true;
  String? _error;
  int? _currentUserId;
  Map<int, ActivityRegistration> _userRegistrations = {};
  Map<int, ActivityRegistration> _memberRegistrations = {};

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateFromController =
      TextEditingController();
  final TextEditingController _startDateToController = TextEditingController();
  final TextEditingController _endDateFromController = TextEditingController();
  final TextEditingController _endDateToController = TextEditingController();
  String _selectedActivityType = 'Svi tipovi';
  String _selectedTroop = 'Svi odredi';
  String _selectedStatus = 'Sve aktivnosti';
  String _selectedSort = 'Najranije prvo';
  double _minFee = 0;
  double _maxFee = 1000;
  DateTime? _startDateFrom;
  DateTime? _startDateTo;
  DateTime? _endDateFrom;
  DateTime? _endDateTo;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateFromController.dispose();
    _startDateToController.dispose();
    _endDateFromController.dispose();
    _endDateToController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);
      final activityTypeProvider = ActivityTypeProvider(authProvider);
      final troopProvider = TroopProvider(authProvider);
      final registrationProvider = ActivityRegistrationProvider(authProvider);

      _activityTypes = await activityTypeProvider.getAllActivityTypes();
      _currentUserId = await authProvider.getUserIdFromToken();

      if (widget.memberId != null ||
          widget.showMyRegistrations ||
          widget.showAllAvailableActivities) {
        final troopResult = await troopProvider.get(
          filter: {"RetrieveAll": true},
        );
        if (troopResult.items != null) {
          _allTroops = troopResult.items!.map((troop) => troop.name).toList();
        }
      }

      if (widget.showMyRegistrations) {
        final userId = await authProvider.getUserIdFromToken();
        if (userId != null) {
          final registrationsResult = await registrationProvider
              .getMemberRegistrations(
                memberId: userId,
                statuses: [
                  0,
                  1,
                  2,
                  3,
                ], // Pending, Approved, Rejected, Cancelled (exclude Completed)
                pageSize: 1000,
              );
          _allRegistrations = (registrationsResult.items ?? [])
              .where((registration) => registration.status != 4)
              .toList();
        }
      } else if (widget.showAllAvailableActivities) {
        final memberProvider = MemberProvider(authProvider);
        final currentMember = await memberProvider.getById(_currentUserId!);

        final allActivitiesResult = await activityProvider.get(
          filter: {
            "RetrieveAll": true,
            "ShowPublicAndOwn": true,
            "OwnTroopId": currentMember.troopId,
          },
        );
        _allActivities = allActivitiesResult.items ?? [];
      } else if (widget.memberId != null) {
        _allActivities = await activityProvider.getMemberActivities(
          widget.memberId!,
        );

        if (widget.showMemberActivities) {
          final memberRegistrationsResult = await registrationProvider
              .getMemberRegistrations(
                memberId: widget.memberId!,
                statuses: [0, 1, 2, 3, 4],
                pageSize: 1000,
              );

          _memberRegistrations = {
            for (var registration in memberRegistrationsResult.items ?? [])
              registration.activityId: registration,
          };
        }
      } else if (widget.troopId != null) {
        _allActivities = await activityProvider.getTroopActivities(
          widget.troopId!,
        );
      }

      if (_currentUserId != null &&
          !widget.showMyRegistrations &&
          _allActivities.isNotEmpty) {
        final userRegistrationsResult = await registrationProvider
            .getMemberRegistrations(
              memberId: _currentUserId,
              statuses: [
                0,
                1,
                2,
                3,
              ],
              pageSize: 1000,
            );

        _userRegistrations = {
          for (var registration in userRegistrationsResult.items ?? [])
            registration.activityId: registration,
        };
      }

      _maxFee = _getMaxFeeForSlider();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Greška pri učitavanju aktivnosti: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      if (widget.showMyRegistrations) {
        _filteredRegistrations = _allRegistrations.where((registration) {
          if (registration.status == 4) {
            return false;
          }

          if (_searchController.text.isNotEmpty) {
            if (!registration.activityTitle.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) &&
                !registration.activityDescription.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                )) {
              return false;
            }
          }

          if (_selectedActivityType != 'Svi tipovi') {
            if (registration.activityTypeName != _selectedActivityType) {
              return false;
            }
          }

          if (widget.memberId != null && _selectedTroop != 'Svi odredi') {
            if (registration.troopName != _selectedTroop) {
              return false;
            }
          }

          if (registration.activityFee < _minFee ||
              registration.activityFee > _maxFee) {
            return false;
          }

          if (_startDateFrom != null &&
              registration.activityStartTime != null) {
            if (registration.activityStartTime!.isBefore(_startDateFrom!)) {
              return false;
            }
          }
          if (_startDateTo != null && registration.activityStartTime != null) {
            if (registration.activityStartTime!.isAfter(_startDateTo!)) {
              return false;
            }
          }

          if (_endDateFrom != null && registration.activityEndTime != null) {
            if (registration.activityEndTime!.isBefore(_endDateFrom!)) {
              return false;
            }
          }
          if (_endDateTo != null && registration.activityEndTime != null) {
            if (registration.activityEndTime!.isAfter(_endDateTo!)) {
              return false;
            }
          }

          return true;
        }).toList();

        _applySorting();
      } else {
        _filteredActivities = _allActivities.where((activity) {
          if (widget.showAllAvailableActivities) {
            if (activity.activityState != 'RegistrationsOpenActivityState') {
              return false;
            }

            if (_userRegistrations.containsKey(activity.id)) {
              return false;
            }
          }

          if (_searchController.text.isNotEmpty) {
            if (!activity.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) &&
                !activity.description.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                )) {
              return false;
            }
          }

          if (_selectedActivityType != 'Svi tipovi') {
            if (activity.activityTypeName != _selectedActivityType) {
              return false;
            }
          }

          if ((widget.memberId != null || widget.showAllAvailableActivities) &&
              _selectedTroop != 'Svi odredi') {
            if (activity.troopName != _selectedTroop) {
              return false;
            }
          }

          if (_selectedStatus != 'Sve aktivnosti') {
            if (widget.showMemberActivities) {
              final registration = _memberRegistrations[activity.id];

              switch (_selectedStatus) {
                case 'Registriran':
                  return registration != null &&
                      (registration.status == 0 || registration.status == 1);
                case 'Odobren':
                  return registration != null && registration.status == 1;
                case 'Odbijen':
                  return registration != null && registration.status == 2;
                case 'Otkazan':
                  return registration != null && registration.status == 3;
                case 'Aktivnost završena':
                  return registration != null && registration.status == 4;
                default:
                  return true;
              }
            } else if (widget.troopId != null) {
              if (_selectedStatus == 'Završene aktivnosti') {
                if (activity.activityState != 'FinishedActivityState') {
                  return false;
                }
              } else if (_selectedStatus == 'Aktivne aktivnosti') {
                if (activity.activityState == 'FinishedActivityState') {
                  return false;
                }
              }
            }
          }

          if (activity.fee < _minFee || activity.fee > _maxFee) {
            return false;
          }

          if (_startDateFrom != null && activity.startTime != null) {
            if (activity.startTime!.isBefore(_startDateFrom!)) {
              return false;
            }
          }
          if (_startDateTo != null && activity.startTime != null) {
            if (activity.startTime!.isAfter(_startDateTo!)) {
              return false;
            }
          }

          if (_endDateFrom != null && activity.endTime != null) {
            if (activity.endTime!.isBefore(_endDateFrom!)) {
              return false;
            }
          }
          if (_endDateTo != null && activity.endTime != null) {
            if (activity.endTime!.isAfter(_endDateTo!)) {
              return false;
            }
          }

          return true;
        }).toList();

        _applySorting();
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedActivityType = 'Svi tipovi';
      _selectedTroop = 'Svi odredi';
      _selectedStatus = 'Sve aktivnosti';
      _selectedSort = 'Najkasnije prvo';
      _minFee = 0;
      _maxFee = _getMaxFeeForSlider();
      _startDateFrom = null;
      _startDateTo = null;
      _endDateFrom = null;
      _endDateTo = null;
    });
    _updateDateControllers();
    _applyFilters();
  }

  void _applySorting() {
    if (widget.showMyRegistrations) {
      _filteredRegistrations.sort((a, b) {
        final dateA = a.activityStartTime ?? a.registeredAt;
        final dateB = b.activityStartTime ?? b.registeredAt;

        if (_selectedSort == 'Najkasnije prvo') {
          return dateB.compareTo(dateA);
        } else {
          return dateA.compareTo(dateB);
        }
      });
    } else {
      _filteredActivities.sort((a, b) {
        final dateA = a.startTime ?? a.createdAt;
        final dateB = b.startTime ?? b.createdAt;

        if (_selectedSort == 'Najkasnije prvo') {
          return dateB.compareTo(dateA);
        } else {
          return dateA.compareTo(dateB);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: widget.title,
      selectedIndex: -1,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: Column(
          children: [
            _buildFilterToggle(),
            if (_showFilters)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbVisibility: MaterialStateProperty.all(true),
                    trackVisibility: MaterialStateProperty.all(true),
                    thickness: MaterialStateProperty.all(12),
                    radius: const Radius.circular(6),
                    thumbColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ),
                    trackColor: MaterialStateProperty.all(
                      Colors.grey.withOpacity(0.2),
                    ),
                    trackBorderColor: MaterialStateProperty.all(
                      Colors.grey.withOpacity(0.3),
                    ),
                    crossAxisMargin: 4,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildFiltersSection(),
                  ),
                ),
              ),
            Expanded(child: SingleChildScrollView(child: _buildBody())),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filteri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _showFilters ? 'Sakrij opcije' : 'Prikaži opcije',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _showFilters
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadActivities,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (widget.showMyRegistrations) {
      if (_filteredRegistrations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _allRegistrations.isEmpty
                    ? 'Nema prijava za aktivnosti'
                    : 'Nema prijava koje odgovaraju filterima',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    } else {
      if (_filteredActivities.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _allActivities.isEmpty
                    ? (widget.showMemberActivities
                          ? '${widget.memberName ?? "Član"} nema aktivnosti u kojima je sudjelovao/la'
                          : widget.showAllAvailableActivities
                          ? 'Nema dostupnih aktivnosti'
                          : widget.memberId != null
                          ? 'Nema aktivnosti u kojima ste sudjelovali'
                          : 'Nema aktivnosti za ovaj odred')
                    : 'Nema aktivnosti koje odgovaraju filterima',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.showMyRegistrations
                ? '${_filteredRegistrations.length} ${_getRegistrationPlural(_filteredRegistrations.length)}'
                : '${_filteredActivities.length} aktivnost${_filteredActivities.length == 1 ? '' : 'i'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.showMyRegistrations)
            ..._filteredRegistrations.map(
              (registration) => _buildRegistrationCard(registration),
            )
          else
            ..._filteredActivities.map(
              (activity) => _buildActivityCard(activity),
            ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(ActivityRegistration registration) {
    final activity = Activity(
      id: registration.activityId,
      title: registration.activityTitle,
      description: registration.activityDescription,
      startTime: registration.activityStartTime,
      endTime: registration.activityEndTime,
      locationName: registration.activityLocationName,
      activityTypeName: registration.activityTypeName,
      activityState: registration.activityState,
      fee: registration.activityFee,
      imagePath: registration.activityImagePath,
      troopName: registration.troopName,
      troopId: registration.troopId,
      activityTypeId: registration.activityTypeId,
      latitude: registration.activityLatitude,
      longitude: registration.activityLongitude,
      createdAt: registration.registeredAt,
      registrationCount: 0,
      pendingRegistrationCount: 0,
      approvedRegistrationCount: 0,
    );

    _userRegistrations[registration.activityId] = registration;

    return _buildActivityCard(activity);
  }

  Widget _buildActivityCard(Activity activity) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActivityDetailsScreen(activity: activity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.imagePath.isNotEmpty) ...[
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    UrlUtils.buildImageUrl(activity.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildListImagePlaceholder();
                    },
                  ),
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity.activityTypeName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildActivityStatus(activity),

                  if (activity.description.isNotEmpty)
                    Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  if (activity.startTime != null ||
                      activity.endTime != null) ...[
                    Row(
                      children: [
                        if (activity.startTime != null) ...[
                          Icon(
                            Icons.play_arrow,
                            size: 16,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateTime(activity.startTime!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (activity.endTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stop, size: 16, color: Colors.red[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateTime(activity.endTime!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],

                  if (activity.locationName.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity.locationName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activity.troopName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activity.fee > 0) ...[
                        Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.fee.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  widget.showMemberActivities
                      ? _buildMemberRegistrationStatus(activity)
                      : _buildRegistrationStatusRow(activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }

  void _updateDateControllers() {
    _startDateFromController.text = _startDateFrom != null
        ? _formatDate(_startDateFrom!)
        : '';
    _startDateToController.text = _startDateTo != null
        ? _formatDate(_startDateTo!)
        : '';
    _endDateFromController.text = _endDateFrom != null
        ? _formatDate(_endDateFrom!)
        : '';
    _endDateToController.text = _endDateTo != null
        ? _formatDate(_endDateTo!)
        : '';
  }

  String _getRegistrationPlural(int count) {
    if (count == 1) {
      return 'prijava';
    }

    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;

    if ((lastDigit == 2 || lastDigit == 3 || lastDigit == 4) &&
        (lastTwoDigits < 12 || lastTwoDigits > 14)) {
      return 'prijave';
    }

    return 'prijava';
  }

  double _getMaxFeeForSlider() {
    if (widget.showMyRegistrations) {
      if (_allRegistrations.isNotEmpty) {
        final maxFee = _allRegistrations
            .map((r) => r.activityFee)
            .reduce((a, b) => a > b ? a : b);
        return maxFee > 0 ? maxFee : 100;
      }
    } else {
      if (_allActivities.isNotEmpty) {
        final maxFee = _allActivities
            .map((a) => a.fee)
            .reduce((a, b) => a > b ? a : b);
        return maxFee > 0 ? maxFee : 100;
      }
    }

    return 100;
  }

  Widget _buildRegistrationStatusRow(Activity activity) {
    if (activity.activityState == 'FinishedActivityState') {
      return const SizedBox.shrink();
    }

    final userRegistration = _getUserRegistration(activity);
    final isUserRegistered = _isUserRegistered(activity);
    final canRegister = _canUserRegister(activity);
    final canCancel = _canUserCancelRegistration(activity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUserRegistered && userRegistration != null) ...[
          _buildUserRegistrationStatus(userRegistration),
          const SizedBox(height: 8),
        ],

        _buildRegistrationButtons(
          activity,
          canRegister,
          canCancel,
          userRegistration,
        ),
      ],
    );
  }

  Widget _buildActivityStatus(Activity activity) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (activity.activityState) {
      case 'RegistrationsOpenActivityState':
        statusText = 'Prijave otvorene';
        statusColor = Colors.green;
        statusIcon = Icons.event_available;
        break;
      case 'RegistrationsClosedActivityState':
        statusText = 'Prijave zatvorene';
        statusColor = Colors.orange;
        statusIcon = Icons.event_busy;
        break;
      case 'FinishedActivityState':
        statusText = 'Završena aktivnost';
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusText = 'Nepoznato stanje';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRegistrationStatus(ActivityRegistration registration) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (registration.status) {
      case 0: // Pending
        statusText = 'Prijava na čekanju';
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 1: // Approved
        statusText = 'Prijava odobrena';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 2: // Rejected
        statusText = 'Prijava odbijena';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 3: // Cancelled
        statusText = 'Prijava otkazana';
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        break;
      case 4: // Completed
        statusText = 'Prisustvovao/la si';
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      default:
        statusText = 'Nepoznato stanje';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationButtons(
    Activity activity,
    bool canRegister,
    bool canCancel,
    ActivityRegistration? userRegistration,
  ) {
    if (canRegister) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _createRegistration(activity),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Prijavi se'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else if (canCancel && userRegistration != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _cancelRegistration(userRegistration),
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('Otkaži prijavu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _cancelRegistration(ActivityRegistration registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkaži prijavu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jeste li sigurni da želite otkazati prijavu za aktivnost "${registration.activityTitle}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nakon otkazivanja nećete moći ponovo se prijaviti za ovu aktivnost.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Otkaži prijavu'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final registrationProvider = ActivityRegistrationProvider(authProvider);

        final cancelledRegistration = await registrationProvider
            .cancelRegistration(registration.id);

        setState(() {
          final registrationIndex = _allRegistrations.indexWhere(
            (r) => r.id == registration.id,
          );
          if (registrationIndex != -1) {
            _allRegistrations[registrationIndex] = cancelledRegistration;
          }

          _userRegistrations[registration.activityId] = cancelledRegistration;
        });
        _applyFilters();

        if (mounted) {
          SnackBarUtils.showSuccessSnackBar(
            'Prijava je uspješno otkazana',
            context: context,
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showErrorSnackBar(e, context: context);
        }
      }
    }
  }

  Future<void> _createRegistration(Activity activity) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ActivityRegistrationScreen(activity: activity),
      ),
    );

    if (result == true && mounted) {
      _loadActivities();

      if (widget.showAllAvailableActivities) {
        Navigator.of(context).pop(true);
      }
    }
  }

  ActivityRegistration? _getUserRegistration(Activity activity) {
    return _userRegistrations[activity.id];
  }

  bool _isUserRegistered(Activity activity) {
    return _userRegistrations.containsKey(activity.id);
  }

  bool _canUserRegister(Activity activity) {
    return activity.activityState == 'RegistrationsOpenActivityState' &&
        !_isUserRegistered(activity);
  }

  bool _canUserCancelRegistration(Activity activity) {
    final registration = _getUserRegistration(activity);
    return registration != null && registration.canCancel;
  }

  Widget _buildMemberRegistrationStatus(Activity activity) {
    final registration = _memberRegistrations[activity.id];

    if (activity.activityState == 'FinishedActivityState') {
      return const SizedBox.shrink();
    }

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (registration == null) {
      statusText = 'Sudjelovao/la';
      statusColor = Colors.blue;
      statusIcon = Icons.done_all;
    } else {
      switch (registration.status) {
        case 0: // Pending
          statusText = 'Prijava na čekanju';
          statusColor = Colors.orange;
          statusIcon = Icons.pending_actions;
          break;
        case 1: // Approved
          statusText = 'Prijava odobrena';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case 2: // Rejected
          statusText = 'Prijava odbijena';
          statusColor = Colors.red;
          statusIcon = Icons.cancel;
          break;
        case 3: // Cancelled
          statusText = 'Prijava otkazana';
          statusColor = Colors.grey;
          statusIcon = Icons.block;
          break;
        case 4: // Completed
          statusText = 'Prisustvovao/la je';
          statusColor = Colors.blue;
          statusIcon = Icons.done_all;
          break;
        default:
          statusText = 'Sudjelovao/la';
          statusColor = Colors.blue;
          statusIcon = Icons.done_all;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'Nema slike',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Resetuj'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pretraži aktivnosti...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedActivityType,
            decoration: InputDecoration(
              labelText: 'Tip aktivnosti',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: 'Svi tipovi',
                child: Text('Svi tipovi'),
              ),
              ..._activityTypes.map(
                (type) =>
                    DropdownMenuItem(value: type.name, child: Text(type.name)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedActivityType = value!;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedSort,
            decoration: InputDecoration(
              labelText: 'Sortiranje',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Najkasnije prvo',
                child: Text('Najkasnije prvo'),
              ),
              DropdownMenuItem(
                value: 'Najranije prvo',
                child: Text('Najranije prvo'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),

          if (widget.troopId != null || widget.showMemberActivities) ...[
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status aktivnosti',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: widget.showMemberActivities
                  ? const [
                      DropdownMenuItem(
                        value: 'Sve aktivnosti',
                        child: Text('Sve aktivnosti'),
                      ),
                      DropdownMenuItem(
                        value: 'Registriran',
                        child: Text('Registriran'),
                      ),
                      DropdownMenuItem(
                        value: 'Odobren',
                        child: Text('Odobren'),
                      ),
                      DropdownMenuItem(
                        value: 'Odbijen',
                        child: Text('Odbijen'),
                      ),
                      DropdownMenuItem(
                        value: 'Otkazan',
                        child: Text('Otkazan'),
                      ),
                      DropdownMenuItem(
                        value: 'Aktivnost završena',
                        child: Text('Aktivnost završena'),
                      ),
                    ]
                  : const [
                      DropdownMenuItem(
                        value: 'Sve aktivnosti',
                        child: Text('Sve aktivnosti'),
                      ),
                      DropdownMenuItem(
                        value: 'Aktivne aktivnosti',
                        child: Text('Aktivne aktivnosti'),
                      ),
                      DropdownMenuItem(
                        value: 'Završene aktivnosti',
                        child: Text('Završene aktivnosti'),
                      ),
                    ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),
          ],

          if (widget.memberId != null ||
              widget.showMyRegistrations ||
              widget.showAllAvailableActivities) ...[
            DropdownButtonFormField<String>(
              value: _selectedTroop,
              decoration: InputDecoration(
                labelText: 'Odred',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'Svi odredi',
                  child: Text('Svi odredi'),
                ),
                ..._allTroops.map(
                  (troopName) => DropdownMenuItem(
                    value: troopName,
                    child: Text(troopName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTroop = value!;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cijena',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_minFee.toStringAsFixed(0)} - ${_maxFee.toStringAsFixed(0)} KM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: RangeValues(
                    _minFee.clamp(0.0, _getMaxFeeForSlider()),
                    _maxFee.clamp(0.0, _getMaxFeeForSlider()),
                  ),
                  min: 0,
                  max: _getMaxFeeForSlider(),
                  divisions: _getMaxFeeForSlider() ~/ 5,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Colors.grey[300],
                  onChanged: (values) {
                    setState(() {
                      _minFee = values.start.round().toDouble();
                      _maxFee = values.end.round().toDouble();
                    });
                    _applyFilters();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 KM',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${_getMaxFeeForSlider().toStringAsFixed(0)} KM',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: [
              const Text(
                'Datum početka',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Od', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _startDateFromController,
                          decoration: InputDecoration(
                            hintText: 'Odaberite',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDateFrom ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              helpText: 'Odaberite datum početka od',
                              cancelText: 'Otkaži',
                              confirmText: 'Potvrdi',
                              fieldHintText: 'DD/MM/YYYY',
                              fieldLabelText: 'Početak od',
                            );
                            if (picked != null) {
                              setState(() {
                                _startDateFrom = picked;
                              });
                              _updateDateControllers();
                              _applyFilters();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Do', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _startDateToController,
                          decoration: InputDecoration(
                            hintText: 'Odaberite',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDateTo ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              helpText: 'Odaberite datum početka do',
                              cancelText: 'Otkaži',
                              confirmText: 'Potvrdi',
                              fieldHintText: 'DD/MM/YYYY',
                              fieldLabelText: 'Početak do',
                            );
                            if (picked != null) {
                              setState(() {
                                _startDateTo = picked;
                              });
                              _updateDateControllers();
                              _applyFilters();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Datum završetka',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Od', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _endDateFromController,
                          decoration: InputDecoration(
                            hintText: 'Odaberite',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDateFrom ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              helpText: 'Odaberite datum završetka od',
                              cancelText: 'Otkaži',
                              confirmText: 'Potvrdi',
                              fieldHintText: 'DD/MM/YYYY',
                              fieldLabelText: 'Završetak od',
                            );
                            if (picked != null) {
                              setState(() {
                                _endDateFrom = picked;
                              });
                              _updateDateControllers();
                              _applyFilters();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Do', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _endDateToController,
                          decoration: InputDecoration(
                            hintText: 'Odaberite',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDateTo ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              helpText: 'Odaberite datum završetka do',
                              cancelText: 'Otkaži',
                              confirmText: 'Potvrdi',
                              fieldHintText: 'DD/MM/YYYY',
                              fieldLabelText: 'Završetak do',
                            );
                            if (picked != null) {
                              setState(() {
                                _endDateTo = picked;
                              });
                              _updateDateControllers();
                              _applyFilters();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
