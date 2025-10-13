import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../layouts/master_screen.dart';
import '../screens/activity_details_screen.dart';
import '../screens/activity_registration_screen.dart';
import '../screens/activity_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> recommendedActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedActivities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadRecommendedActivities();
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
                ],
              ),
            ),
          ),
        );
      },
    );
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
            Container(
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

            Padding(
              padding: const EdgeInsets.all(12.0),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    });
    await _loadRecommendedActivities();
  }
}
