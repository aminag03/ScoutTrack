import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/admin_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/models/admin_dashboard.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scouttrack_desktop/ui/shared/screens/troop_details_screen.dart';

class AdminHomePage extends StatefulWidget {
  final String username;
  const AdminHomePage({super.key, required this.username});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AdminDashboard? _dashboard;
  bool _isLoading = true;
  int? _selectedYear;
  int _timePeriodDays = 30;
  String? _adminName;

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
        final adminId = userInfo['id'] as int?;
        if (adminId != null) {
          final adminProvider = AdminProvider(authProvider);

          final admin = await adminProvider.getById(adminId);
          _adminName = admin.username.isNotEmpty
              ? admin.username
              : widget.username;

          final dashboard = await adminProvider.getDashboard(
            year: _selectedYear,
            timePeriodDays: _timePeriodDays,
          );

          if (mounted) {
            setState(() {
              _dashboard = dashboard;
              _isLoading = false;
            });

            _assignCategoryColors();
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

  void _assignCategoryColors() {
    if (_dashboard != null) {
      for (var category in _dashboard!.scoutCategories) {
        if (category.color.isEmpty || category.color == '#4F8055') {
          category.color = _getCategoryColor(category.name);
        }
      }
    }
  }

  String _getCategoryColor(String categoryName) {
    final hash = categoryName.hashCode;
    final hue = (hash.abs() % 360).toDouble();

    final saturation = 0.6 + (hash.abs() % 30) / 100.0;
    final lightness = 0.4 + (hash.abs() % 30) / 100.0;

    final hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
    final rgbColor = hslColor.toColor();

    return '#${rgbColor.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _getGreenShadeByIndex(int index) {
    final greenShades = <Color>[
      const Color(0xFF2E7D32),
      const Color(0xFF388E3C),
      const Color(0xFF4CAF50),
      const Color(0xFF66BB6A),
      const Color(0xFF81C784),
      const Color(0xFFA5D6A7),
      const Color(0xFF1B5E20),
      const Color(0xFF43A047),
      const Color(0xFF7CB342),
      const Color(0xFF9CCC65),
      const Color(0xFF689F38),
      const Color(0xFF8BC34A),
      const Color(0xFF33691E),
      const Color(0xFF558B2F),
      const Color(0xFF6ABF47),
      const Color(0xFF8DCA3A),
      const Color(0xFF1B4332),
      const Color(0xFF2D5016),
      const Color(0xFF4A6741),
      const Color(0xFF6B8E23),
    ];

    return greenShades[index % greenShades.length];
  }

  String _getMonthAbbreviation(String monthName) {
    switch (monthName.toLowerCase()) {
      case 'januar':
        return 'Jan';
      case 'februar':
        return 'Feb';
      case 'mart':
        return 'Mar';
      case 'april':
        return 'Apr';
      case 'maj':
        return 'Maj';
      case 'juni':
        return 'Jun';
      case 'juli':
        return 'Jul';
      case 'august':
        return 'Avg';
      case 'septembar':
        return 'Sep';
      case 'oktobar':
        return 'Okt';
      case 'novembar':
        return 'Nov';
      case 'decembar':
        return 'Dec';
      default:
        return monthName.length > 3 ? monthName.substring(0, 3) : monthName;
    }
  }

  Future<void> _navigateToTroopDetails(MostActiveTroop troop) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo != null) {
        final troopProvider = TroopProvider(authProvider);
        final fullTroop = await troopProvider.getById(troop.id);

        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TroopDetailsScreen(
                  troop: fullTroop,
                  role: userInfo['role'] ?? 'Admin',
                  loggedInUserId: userInfo['id'] ?? 0,
                  selectedMenu: 'Početna',
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );

        if (result == true) {
          _loadDashboard();
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(
          context,
          'Greška pri navigaciji do detalja odreda: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: 'Admin',
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
                  'Dobrodošli, ${_adminName?.isNotEmpty == true ? _adminName : widget.username}!',
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

          _buildMetricsCards(),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildMostActiveTroopsCard()),
              const SizedBox(width: 24),

              Expanded(flex: 1, child: _buildMonthlyActivitiesCard()),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildScoutCategoriesCard()),
              const SizedBox(width: 24),

              Expanded(flex: 1, child: _buildMonthlyAttendanceCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Odredi',
            _dashboard!.troopCount.toString(),
            Icons.groups,
            const Color(0xFF4F8055),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Članovi',
            _dashboard!.memberCount.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Broj aktivnosti',
            _dashboard!.activityCount.toString(),
            Icons.event,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Broj objava',
            _dashboard!.postCount.toString(),
            Icons.camera_alt,
            Colors.purple,
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

  Widget _buildMostActiveTroopsCard() {
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
                  'Najaktivniji odredi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                DropdownButton<int>(
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
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _timePeriodDays = value;
                      });
                      _loadDashboard();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard!.mostActiveTroops.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Nema podataka o aktivnosti odreda',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              _buildTroopsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTroopsTable() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
      children: [
        const TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ODRED',
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
          ],
        ),
        ..._dashboard!.mostActiveTroops.map(
          (troop) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildClickableTroopName(troop),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  troop.activityCount.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableTroopName(MostActiveTroop troop) {
    return _ClickableTroopName(
      troop: troop,
      onTap: () => _navigateToTroopDetails(troop),
    );
  }

  Widget _buildMonthlyActivitiesCard() {
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
                  'Mjesečne aktivnosti',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_dashboard!.availableYears.isNotEmpty)
                  DropdownButton<int>(
                    value: _selectedYear ?? _dashboard!.availableYears.first,
                    items: _dashboard!.availableYears
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
            SizedBox(height: 300, child: _buildActivitiesChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesChart() {
    final maxValue = _dashboard!.monthlyActivities
        .map((e) => e.activityCount)
        .fold(0, (max, value) => value > max ? value : max);

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
                  monthIndex < _dashboard!.monthlyActivities.length
                  ? _dashboard!.monthlyActivities[monthIndex].monthName
                  : '';

              return BarTooltipItem(
                '$monthName\n${value.toInt()} aktivnosti',
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
                    value.toInt() < _dashboard!.monthlyActivities.length) {
                  return Text(
                    _getMonthAbbreviation(
                      _dashboard!.monthlyActivities[value.toInt()].monthName,
                    ),
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
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
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
        barGroups: _dashboard!.monthlyActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.activityCount.toDouble(),
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

  Widget _buildScoutCategoriesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Izviđačke kategorije',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 280, child: _buildCategoriesPieChart()),
            const SizedBox(height: 16),
            _buildCategoriesLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPieChart() {
    if (_dashboard!.scoutCategories.isEmpty) {
      return const Center(
        child: Text(
          'Nema podataka o kategorijama',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    _assignCategoryColors();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _dashboard!.scoutCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;

          final color = _getGreenShadeByIndex(index);

          return PieChartSectionData(
            color: color,
            value: category.percentage,
            title: '${category.percentage.toStringAsFixed(0)}%',
            radius: 120,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoriesLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _dashboard!.scoutCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;

        final color = _getGreenShadeByIndex(index);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(category.name, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
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
                Expanded(
                  child: Text(
                    'Prosječan broj prisustava po mjesecima',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (_dashboard!.availableYears.isNotEmpty)
                  DropdownButton<int>(
                    value: _selectedYear ?? _dashboard!.availableYears.first,
                    items: _dashboard!.availableYears
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
                    _getMonthAbbreviation(
                      _dashboard!.monthlyAttendance[value.toInt()].monthName,
                    ),
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
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
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

class _ClickableTroopName extends StatefulWidget {
  final MostActiveTroop troop;
  final VoidCallback onTap;

  const _ClickableTroopName({required this.troop, required this.onTap});

  @override
  State<_ClickableTroopName> createState() => _ClickableTroopNameState();
}

class _ClickableTroopNameState extends State<_ClickableTroopName> {
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
            widget.troop.name,
            style: TextStyle(
              color: isHovered
                  ? const Color(0xFF2E5A33)
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
