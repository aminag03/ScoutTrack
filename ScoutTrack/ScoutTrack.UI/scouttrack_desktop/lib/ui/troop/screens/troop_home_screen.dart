import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/activity_provider.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/models/troop_dashboard.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/activity_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_details_screen.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TroopHomePage extends StatefulWidget {
  final String username;
  const TroopHomePage({super.key, required this.username});

  @override
  State<TroopHomePage> createState() => _TroopHomePageState();
}

class _TroopHomePageState extends State<TroopHomePage> {
  TroopDashboard? _dashboard;
  bool _isLoading = true;
  int? _selectedYear;
  int? _timePeriodDays = 30;
  int? _troopId;
  String? _troopName;
  List<int> _cachedAvailableYears = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo != null) {
        _troopId = userInfo['id'] as int?;
        if (_troopId != null) {
          final troopProvider = TroopProvider(authProvider);

          // Fetch troop details to get the troop name
          final troop = await troopProvider.getById(_troopId!);

          final dashboard = await troopProvider.getDashboard(
            _troopId!,
            year: _selectedYear,
            timePeriodDays: _timePeriodDays,
          );

          if (mounted) {
            setState(() {
              _dashboard = dashboard;
              _troopName = troop.username.isNotEmpty
                  ? troop.username
                  : widget.username;
              // Cache available years on first load only
              if (_cachedAvailableYears.isEmpty &&
                  dashboard.availableYears.isNotEmpty) {
                _cachedAvailableYears = dashboard.availableYears;
              }
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(
          context,
          'Greška pri učitavanju dashboard podataka: $e',
        );
      }
    }
  }

  Future<void> _navigateToActivity(UpcomingActivity activity) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);
      final fullActivity = await activityProvider.getById(activity.id);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActivityDetailsScreen(activity: fullActivity),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(
          context,
          'Nije moguće učitati podatke o aktivnosti: $e',
        );
      }
    }
  }

  Future<void> _navigateToMember(MostActiveMember member) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = MemberProvider(authProvider);
      final fullMember = await memberProvider.getById(member.id);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemberDetailsScreen(
              member: fullMember,
              role: 'Troop',
              loggedInUserId: _troopId ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Nije moguće učitati podatke o članu: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: 'Troop',
      selectedMenu: 'Početna',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboard == null
          ? const Center(child: Text('Nema podataka za prikaz'))
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4F8055),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Dobrodošli, ${_troopName ?? widget.username}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Top metrics cards
          _buildMetricsCards(),
          const SizedBox(height: 24),

          // Main content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Upcoming activities
              Expanded(flex: 1, child: _buildUpcomingActivitiesCard()),
              const SizedBox(width: 24),

              // Right column - Most active members
              Expanded(flex: 1, child: _buildMostActiveMembersCard()),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly attendance chart
          _buildMonthlyAttendanceCard(),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Članovi',
            _dashboard!.memberCount.toString(),
            Icons.people,
            const Color(0xFF4F8055),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Prijave na čekanju',
            _dashboard!.pendingRegistrationCount.toString(),
            Icons.star_outline,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Broj aktivnosti',
            _dashboard!.activityCount.toString(),
            Icons.event,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingActivitiesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nadolazeće aktivnosti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_dashboard!.upcomingActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Nema nadolazećih aktivnosti',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ..._dashboard!.upcomingActivities.map(
                (activity) => _buildActivityItem(activity),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(UpcomingActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _navigateToActivity(activity),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.star_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d. M. yyyy.').format(activity.startTime),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMostActiveMembersCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Najaktivniji članovi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DropdownButton<int?>(
                  value: _timePeriodDays,
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Zadnjih 7 dana')),
                    DropdownMenuItem(
                      value: 30,
                      child: Text('Zadnjih mjesec dana'),
                    ),
                    DropdownMenuItem(
                      value: 90,
                      child: Text('Zadnjih 3 mjeseca'),
                    ),
                    DropdownMenuItem(value: 365, child: Text('Zadnja godina')),
                    DropdownMenuItem(value: null, child: Text('Sve vrijeme')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _timePeriodDays = value;
                    });
                    _loadDashboard();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard!.mostActiveMembers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Nema podataka o aktivnosti članova',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              _buildMembersTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'IME I PREZIME',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'BROJ AKTIVNOSTI',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'BROJ OBJAVA',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        ..._dashboard!.mostActiveMembers.map(
          (member) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildClickableMemberName(member),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  member.activityCount.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  member.postCount.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableMemberName(MostActiveMember member) {
    return _ClickableMemberName(
      member: member,
      onTap: () => _navigateToMember(member),
    );
  }

  Widget _buildMonthlyAttendanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Prosječan broj prisustava po mjesecima',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_cachedAvailableYears.isNotEmpty)
                  DropdownButton<int>(
                    value: _selectedYear ?? _cachedAvailableYears.first,
                    items: _cachedAvailableYears
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                        _loadDashboard();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 300, child: _buildAttendanceChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    final maxValue = _dashboard!.monthlyAttendance
        .map((e) => e.averageAttendance)
        .fold(0.0, (max, value) => value > max ? value : max);

    // Ensure we have a reasonable max value for the chart
    final maxY = maxValue > 0 ? (maxValue * 1.2).ceil().toDouble() : 10.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final monthIndex = group.x;
              final value = rod.toY;
              final monthName =
                  monthIndex < _dashboard!.monthlyAttendance.length
                  ? _dashboard!.monthlyAttendance[monthIndex].monthName
                  : '';

              return BarTooltipItem(
                '$monthName\n${value.toStringAsFixed(1)} prisustava',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < _dashboard!.monthlyAttendance.length) {
                  return Text(
                    _dashboard!.monthlyAttendance[value.toInt()].monthName,
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5, // Show 5 intervals instead of 10
              getTitlesWidget: (value, meta) {
                // Only show integer values and ensure they're reasonable
                if (value == value.toInt().toDouble() && value >= 0) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _dashboard!.monthlyAttendance.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.averageAttendance,
                color: const Color(0xFF4F8055),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ClickableMemberName extends StatefulWidget {
  final MostActiveMember member;
  final VoidCallback onTap;

  const _ClickableMemberName({required this.member, required this.onTap});

  @override
  State<_ClickableMemberName> createState() => _ClickableMemberNameState();
}

class _ClickableMemberNameState extends State<_ClickableMemberName> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xFF4F8055).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isHovered
                ? Border.all(color: const Color(0xFF4F8055).withOpacity(0.3))
                : null,
          ),
          child: Text(
            widget.member.fullName,
            style: TextStyle(
              color: isHovered
                  ? const Color(0xFF2E5A33) // Darker green on hover
                  : const Color(0xFF4F8055),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: isHovered
                  ? const Color(0xFF2E5A33)
                  : const Color(0xFF4F8055),
              decorationThickness: isHovered ? 2.0 : 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
