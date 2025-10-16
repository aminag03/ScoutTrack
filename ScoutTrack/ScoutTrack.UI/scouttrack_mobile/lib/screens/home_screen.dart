import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/badge_provider.dart';
import '../providers/member_badge_provider.dart';
import '../models/activity.dart';
import '../models/member_badge.dart';
import '../models/badge_requirement.dart';
import '../models/member_badge_progress.dart';
import '../models/badge.dart';
import '../layouts/master_screen.dart';
import '../screens/activity_details_screen.dart';
import '../screens/activity_registration_screen.dart';
import '../screens/activity_list_screen.dart';
import '../screens/badge_list_screen.dart';
import '../screens/activity_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> recommendedActivities = [];
  bool isLoading = true;

  MemberBadge? topInProgressBadge;
  String? topBadgeName;
  String? topBadgeImageUrl;
  double topBadgeProgress = 0.0;
  bool isLoadingBadges = true;

  List<Activity> upcomingActivities = [];
  bool isLoadingUpcomingActivities = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadRecommendedActivities(),
      _loadTopInProgressBadge(),
      _loadUpcomingActivities(),
    ]);
  }

  Future<void> _loadRecommendedActivities() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);

      final activities = await activityProvider.getRecommendedActivities(
        topN: 5,
      );

      if (mounted) {
        setState(() {
          recommendedActivities = activities;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTopInProgressBadge() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      final userInfo = await authProvider.getCurrentUserInfo();
      if (userInfo == null || userInfo['id'] == null) {
        if (mounted) {
          setState(() {
            isLoadingBadges = false;
          });
        }
        return;
      }

      final memberId = userInfo['id'] as int;

      final futures = await Future.wait([
        badgeProvider.get(filter: {"RetrieveAll": true}),
        memberBadgeProvider.getMemberBadges(memberId),
      ]);

      final badgeResult = futures[0] as dynamic;
      final memberBadges = futures[1] as List<MemberBadge>;

      final allBadges = badgeResult.items ?? [];
      final inProgressBadges = memberBadges
          .where((mb) => mb.status == MemberBadgeStatus.inProgress)
          .toList();

      if (inProgressBadges.isEmpty) {
        if (mounted) {
          setState(() {
            isLoadingBadges = false;
          });
        }
        return;
      }

      double maxProgress = -1;
      MemberBadge? topBadge;
      String? topName;
      String? topImageUrl;

      for (final memberBadge in inProgressBadges) {
        final badgeList = allBadges
            .where((b) => b.id == memberBadge.badgeId)
            .toList();

        if (badgeList.isEmpty) {
          continue;
        }

        final badge = badgeList.first;

        try {
          final futures = await Future.wait([
            badgeProvider.getBadgeRequirements(badge.id),
            memberBadgeProvider.getMemberBadgeProgress(memberBadge.id),
          ]);

          final requirements = futures[0] as List<BadgeRequirement>;
          final progress = futures[1] as List<MemberBadgeProgress>;

          if (requirements.isEmpty) continue;

          final completedCount = progress.where((p) => p.isCompleted).length;
          final progressPercentage =
              (completedCount / requirements.length) * 100;

          if (progressPercentage > maxProgress) {
            maxProgress = progressPercentage;
            topBadge = memberBadge;
            topName = badge.name;
            topImageUrl = badge.imageUrl;
          }
        } catch (e) {
          continue;
        }
      }

      if (mounted) {
        setState(() {
          if (maxProgress >= 0 && topBadge != null) {
            topInProgressBadge = topBadge;
            topBadgeName = topName;
            topBadgeImageUrl = topImageUrl;
            topBadgeProgress = maxProgress;
          } else {
            topInProgressBadge = null;
            topBadgeName = null;
            topBadgeImageUrl = null;
            topBadgeProgress = 0.0;
          }
          isLoadingBadges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingBadges = false;
        });
      }
    }
  }

  Future<void> _loadUpcomingActivities() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);

      final userInfo = await authProvider.getCurrentUserInfo();
      if (userInfo == null || userInfo['id'] == null) {
        if (mounted) {
          setState(() {
            isLoadingUpcomingActivities = false;
          });
        }
        return;
      }

      final memberId = userInfo['id'] as int;

      final activity = await activityProvider.getEarliestUpcomingActivity(
        memberId,
      );

      if (mounted) {
        setState(() {
          upcomingActivities = activity != null ? [activity] : [];
          isLoadingUpcomingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingUpcomingActivities = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final username = authProvider.username;

        return MasterScreen(
          headerTitle: 'Zdravo, ${username ?? 'User'}!',
          selectedIndex: 0,
          body: Container(
            color: const Color(0xFFF5F5DC),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecommendedActivitiesSection(),
                  const SizedBox(height: 24),
                  _buildBadgeProgressSection(),
                  const SizedBox(height: 24),
                  _buildUpcomingActivitiesSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topInProgressBadge != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BadgeListScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Napredak na vještarstvima',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          const Text(
            'Napredak na vještarstvima',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 16),
        if (isLoadingBadges)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          )
        else if (topInProgressBadge == null)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 32,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nema aktivnih vještarstava',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          _buildBadgeCard(),
      ],
    );
  }

  Widget _buildBadgeCard() {
    return GestureDetector(
      onTap: () => _showBadgeDetails(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF558B6E).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF558B6E), width: 2),
              ),
              child: topBadgeImageUrl != null && topBadgeImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        topBadgeImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFF558B6E),
                              size: 28,
                            ),
                      ),
                    )
                  : const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF558B6E),
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topBadgeName ?? 'Vještarstvo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: topBadgeProgress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF558B6E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${topBadgeProgress.toInt()}% završeno',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF558B6E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails() async {
    if (topInProgressBadge == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);

      final badgeResult = await badgeProvider.get(
        filter: {"RetrieveAll": true},
      );
      final allBadges = badgeResult.items ?? [];

      final badgeList = allBadges
          .where((b) => b.id == topInProgressBadge!.badgeId)
          .toList();

      if (badgeList.isNotEmpty) {
        final badge = badgeList.first;
        showDialog(
          context: context,
          builder: (context) => _BadgeDetailsDialog(
            badge: badge,
            memberBadge: topInProgressBadge,
          ),
        );
      }
    } catch (e) {
      print('Error showing badge details: $e');
    }
  }

  Widget _buildUpcomingActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcomingActivities.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ActivityCalendarScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nadolazeći događaji',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          const Text(
            'Nadolazeći događaji',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 16),
        if (isLoadingUpcomingActivities)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          )
        else if (upcomingActivities.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Nema nadolazećih događaja',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          _buildUpcomingActivityCard(upcomingActivities.first),
      ],
    );
  }

  Widget _buildUpcomingActivityCard(Activity activity) {
    return GestureDetector(
      onTap: () => _showActivityDetails(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${activity.startTime!.day}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    _getMonthName(activity.startTime!.month),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E7D32),
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
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(activity.startTime!),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Avg',
      'Sep',
      'Okt',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}. ${date.month.toString().padLeft(2, '0')}. ${date.year}.';
  }

  Widget _buildRecommendedActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preporučene aktivnosti',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          )
        else if (recommendedActivities.isEmpty)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_work, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Nema preporučenih aktivnosti',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendedActivities.length,
              itemBuilder: (context, index) {
                return _buildActivityCard(recommendedActivities[index]);
              },
            ),
          ),
        const SizedBox(height: 12),
        if (recommendedActivities.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showAllActivities,
              child: const Text(
                'Prikaži više',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return SizedBox(
      width: 250,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showActivityDetails(activity),
              child: Container(
                height: 140,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Color(0xFF4CAF50),
                ),
                child: activity.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          activity.imagePath,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: _getDefaultActivityIcon());
                          },
                        ),
                      )
                    : Center(child: _getDefaultActivityIcon()),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showActivityDetails(activity),
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateRange(activity.startTime, activity.endTime),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.locationName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showActivityDetails(activity),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2E7D32)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                          ),
                          child: const Text(
                            'Detalji',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _registerForActivity(activity),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                          ),
                          child: const Text(
                            'Prijavi se',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDefaultActivityIcon() {
    return const Icon(Icons.event_note, size: 60, color: Colors.white);
  }

  String _formatDateRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) return '';

    final startDate =
        startTime.day.toString().padLeft(2, '0') +
        '. ${startTime.month.toString().padLeft(2, '0')}.' +
        ' ${startTime.year}.';

    if (endTime != null && endTime != startTime) {
      final endDate =
          endTime.day.toString().padLeft(2, '0') +
          '. ${endTime.month.toString().padLeft(2, '0')}.' +
          ' ${endTime.year}.';
      return '$startDate - $endDate';
    }

    return startDate;
  }

  void _showActivityDetails(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityDetailsScreen(activity: activity),
      ),
    );
  }

  void _registerForActivity(Activity activity) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityRegistrationScreen(activity: activity),
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });
      await _loadRecommendedActivities();
    } else {
      print('Registration failed or cancelled, not refreshing');
    }
  }

  void _showAllActivities() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActivityListScreen(
          title: 'Dostupne aktivnosti',
          showAllAvailableActivities: true,
        ),
      ),
    );

    setState(() {
      isLoading = true;
      isLoadingUpcomingActivities = true;
    });
    await _loadRecommendedActivities();
    await _loadUpcomingActivities();
  }
}

class _BadgeDetailsDialog extends StatefulWidget {
  final ScoutBadge badge;
  final MemberBadge? memberBadge;

  const _BadgeDetailsDialog({required this.badge, this.memberBadge});

  @override
  State<_BadgeDetailsDialog> createState() => _BadgeDetailsDialogState();
}

class _BadgeDetailsDialogState extends State<_BadgeDetailsDialog> {
  List<BadgeRequirement> _requirements = [];
  List<MemberBadgeProgress> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadgeDetails();
  }

  Future<void> _loadBadgeDetails() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);

      final futures = <Future>[
        badgeProvider.getBadgeRequirements(widget.badge.id),
      ];

      if (widget.memberBadge != null) {
        final memberBadgeProvider = MemberBadgeProvider(authProvider);
        futures.add(
          memberBadgeProvider.getMemberBadgeProgress(widget.memberBadge!.id),
        );
      }

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          _requirements = results[0] as List<BadgeRequirement>;
          _progress = results.length > 1
              ? results[1] as List<MemberBadgeProgress>
              : <MemberBadgeProgress>[];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateProgress() {
    if (_requirements.isEmpty || widget.memberBadge == null) return 0.0;
    final completedCount = _progress.where((p) => p.isCompleted).length;
    return (completedCount / _requirements.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF558B6E),
                        width: 3,
                      ),
                    ),
                    child: widget.badge.imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              widget.badge.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFF558B6E),
                                    size: 36,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF558B6E),
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.badge.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.badge.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.badge.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRequirementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_requirements.isNotEmpty) ...[
            if (widget.memberBadge != null) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _calculateProgress() / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF558B6E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_calculateProgress().toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF558B6E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Uslovi:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...(_requirements.map(
              (requirement) => _buildRequirementItem(requirement),
            )),
          ] else
            const Text(
              'Nema dostupnih uslova za ovo vještarstvo.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BadgeRequirement requirement) {
    final progress = _progress.isNotEmpty
        ? _progress.firstWhere(
            (p) => p.requirementId == requirement.id,
            orElse: () => MemberBadgeProgress(
              requirementId: requirement.id,
              isCompleted: false,
              createdAt: DateTime.now(),
            ),
          )
        : MemberBadgeProgress(
            requirementId: requirement.id,
            isCompleted: false,
            createdAt: DateTime.now(),
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            progress.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: progress.isCompleted ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: progress.isCompleted
                        ? Colors.green[700]
                        : Colors.black87,
                    decoration: progress.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (progress.isCompleted && progress.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Završeno: ${_formatDate(progress.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }
}
