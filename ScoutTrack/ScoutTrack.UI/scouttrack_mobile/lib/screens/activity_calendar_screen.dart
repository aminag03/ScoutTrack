import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/troop_provider.dart';
import '../providers/activity_registration_provider.dart';
import '../models/activity.dart';
import '../models/activity_registration.dart';
import '../layouts/master_screen.dart';
import '../utils/snackbar_utils.dart';
import 'activity_details_screen.dart';
import 'activity_registration_screen.dart';

class ActivityCalendarScreen extends StatefulWidget {
  const ActivityCalendarScreen({super.key});

  @override
  State<ActivityCalendarScreen> createState() => _ActivityCalendarScreenState();
}

class _ActivityCalendarScreenState extends State<ActivityCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  int? _selectedTroopId;
  List<Map<String, dynamic>> _troops = [];
  List<Activity> _activities = [];
  Map<int, ActivityRegistration> _userRegistrations = {};
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final troopProvider = TroopProvider(authProvider);

    try {
      final result = await troopProvider.get();
      setState(() {
        _troops =
            result.items
                ?.map((troop) => {'id': troop.id, 'name': troop.name})
                .toList() ??
            [];
      });
    } catch (e) {
      // Handle error silently for now
    }

    final userInfo = await authProvider.getCurrentUserInfo();
    if (userInfo != null && userInfo['id'] != null) {
      _currentUserId = userInfo['id'] as int;
    }

    await _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);

      final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endOfMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        0,
      );

      final filter = <String, dynamic>{};

      final result = await activityProvider.get(filter: filter);
      final allActivities = result.items ?? [];

      _activities = allActivities.where((activity) {
        if (activity.activityState == 'DraftActivityState' ||
            activity.activityState == 'CancelledActivityState') {
          return false;
        }

        if (activity.startTime == null) {
          return false;
        }

        final startDate = activity.startTime!;
        final endDate = activity.endTime ?? startDate;

        final isInCurrentMonth =
            (startDate.isBefore(endOfMonth.add(const Duration(days: 1))) &&
            endDate.isAfter(startOfMonth.subtract(const Duration(days: 1))));

        if (_selectedTroopId != null) {
          final matchesTroop = activity.troopId == _selectedTroopId;
          return isInCurrentMonth && matchesTroop;
        }

        return isInCurrentMonth;
      }).toList();

      if (_currentUserId != null && _activities.isNotEmpty) {
        await _loadUserRegistrations();
      }

      _selectDayWithActivities();

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _loadUserRegistrations() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final registrationProvider = ActivityRegistrationProvider(authProvider);

      final userRegistrationsResult = await registrationProvider
          .getMemberRegistrations(
            memberId: _currentUserId!,
            statuses: [0, 1], // Pending and Approved
            pageSize: 1000,
          );

      _userRegistrations = {
        for (var registration in userRegistrationsResult.items ?? [])
          if (registration.activityState != 'DraftActivityState' &&
              registration.activityState != 'CancelledActivityState')
            registration.activityId: registration,
      };
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _selectDayWithActivities() {
    if (_activities.isEmpty) {
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      return;
    }

    for (int day = 1; day <= 31; day++) {
      try {
        final testDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        if (_hasActivitiesOnDate(testDate)) {
          _selectedDate = testDate;
          return;
        }
      } catch (e) {
        continue;
      }
    }

    _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Kalendar aktivnosti',
      selectedIndex: 0,
      showBackButton: true,
      body: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _loadInitialData();
          }
        },
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Odred',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedTroopId,
                      hint: const Text('Odaberi odred'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Svi odredi'),
                        ),
                        ..._troops.map((troop) {
                          return DropdownMenuItem<int?>(
                            value: troop['id'],
                            child: Text(troop['name']),
                          );
                        }),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedTroopId = newValue;
                        });
                        _loadActivities();
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    _buildCalendar(),
                    const SizedBox(height: 16),
                    _buildActivityCards(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
              _loadActivities();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
              _loadActivities();
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstDayWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0-6 (Sunday = 0)

    final daysInMonth = lastDayOfMonth.day;
    final daysInPreviousMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: ['N', 'P', 'U', 'S', 'Č', 'P', 'S']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                for (int week = 0; week < 6; week++)
                  Row(
                    children: [
                      for (int day = 0; day < 7; day++)
                        Expanded(
                          child: _buildCalendarDay(
                            week,
                            day,
                            firstDayWeekday,
                            daysInPreviousMonth,
                            daysInMonth,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    int week,
    int day,
    int firstDayWeekday,
    int daysInPreviousMonth,
    int daysInMonth,
  ) {
    final dayNumber = week * 7 + day - firstDayWeekday + 1;
    final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
    final isPreviousMonth = dayNumber <= 0;

    DateTime dayDate;
    if (isCurrentMonth) {
      dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
    } else if (isPreviousMonth) {
      dayDate = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        daysInPreviousMonth + dayNumber,
      );
    } else {
      dayDate = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        dayNumber - daysInMonth,
      );
    }

    final hasActivities = _hasActivitiesOnDate(dayDate);
    final isSelected =
        isCurrentMonth &&
        dayDate.day == _selectedDate.day &&
        dayDate.month == _selectedDate.month &&
        dayDate.year == _selectedDate.year;

    return GestureDetector(
      onTap: isCurrentMonth
          ? () {
              setState(() {
                _selectedDate = dayDate;
              });
            }
          : null,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            isCurrentMonth
                ? dayNumber.toString()
                : isPreviousMonth
                ? (daysInPreviousMonth + dayNumber).toString()
                : (dayNumber - daysInMonth).toString(),
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                  ? (hasActivities ? Colors.green[600] : Colors.black)
                  : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  bool _hasActivitiesOnDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final hasActivities = _activities.any((activity) {
      if (activity.startTime == null) return false;

      final startDate = activity.startTime!;
      final endDate = activity.endTime ?? startDate;

      final normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      final isInRange =
          (normalizedDate.isAtSameMomentAs(normalizedStartDate) ||
              normalizedDate.isAfter(normalizedStartDate)) &&
          (normalizedDate.isAtSameMomentAs(normalizedEndDate) ||
              normalizedDate.isBefore(normalizedEndDate));

      return isInRange;
    });

    return hasActivities;
  }

  Widget _buildActivityCards() {
    final activitiesForSelectedDate = _getActivitiesForDate(_selectedDate);

    if (activitiesForSelectedDate.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Nema aktivnosti za odabrani dan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: activitiesForSelectedDate
          .map((activity) => _buildActivityCard(activity))
          .toList(),
    );
  }

  List<Activity> _getActivitiesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final activities = _activities.where((activity) {
      if (activity.startTime == null) return false;

      final startDate = activity.startTime!;
      final endDate = activity.endTime ?? startDate;

      final normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      final isInRange =
          (normalizedDate.isAtSameMomentAs(normalizedStartDate) ||
              normalizedDate.isAfter(normalizedStartDate)) &&
          (normalizedDate.isAtSameMomentAs(normalizedEndDate) ||
              normalizedDate.isBefore(normalizedEndDate));

      return isInRange;
    }).toList();

    return activities;
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActivityDetailsScreen(activity: activity),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${activity.startTime!.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            _getMonthName(activity.startTime!.month),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(activity.startTime!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _buildRegistrationButton(activity),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Januar',
      'Februar',
      'Mart',
      'April',
      'Maj',
      'Juni',
      'Juli',
      'Avgust',
      'Septembar',
      'Oktobar',
      'Novembar',
      'Decembar',
    ];
    return months[month];
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

  Widget _buildRegistrationButton(Activity activity) {
    final canRegister = _canUserRegister(activity);
    final canCancel = _canUserCancelRegistration(activity);
    final userRegistration = _getUserRegistration(activity);

    if (canRegister) {
      return GestureDetector(
        onTap: () => _createRegistration(activity),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Prijavi se',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (canCancel && userRegistration != null) {
      return GestureDetector(
        onTap: () => _cancelRegistration(userRegistration),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Otkaži prijavu',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _createRegistration(Activity activity) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ActivityRegistrationScreen(activity: activity),
      ),
    );

    if (result == true && mounted) {
      await _loadUserRegistrations();
      setState(() {});
    }
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
                      'Vaša prijava će biti obrisana. Možete se ponovo prijaviti ako želite.',
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

        final success = await registrationProvider.cancelRegistration(
          registration.id,
        );

        if (success) {
          setState(() {
            _userRegistrations.remove(registration.activityId);
          });

          if (mounted) {
            SnackBarUtils.showSuccessSnackBar(
              'Prijava je uspješno otkazana',
              context: context,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showErrorSnackBar(e, context: context);
        }
      }
    }
  }
}
