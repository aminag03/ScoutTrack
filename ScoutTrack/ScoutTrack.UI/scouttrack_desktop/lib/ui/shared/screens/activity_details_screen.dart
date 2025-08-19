import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/activity_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/permission_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_utils.dart';
import 'package:scouttrack_desktop/providers/activity_equipment_provider.dart';
import 'package:scouttrack_desktop/models/activity_equipment.dart';
import 'package:scouttrack_desktop/providers/activity_registration_provider.dart';
import 'package:scouttrack_desktop/models/activity_registration.dart';
import 'package:scouttrack_desktop/providers/review_provider.dart';
import 'package:scouttrack_desktop/models/review.dart';
import 'package:scouttrack_desktop/providers/post_provider.dart';
import 'package:scouttrack_desktop/models/post.dart';
import 'package:scouttrack_desktop/providers/comment_provider.dart';
import 'package:scouttrack_desktop/models/comment.dart';
import 'package:scouttrack_desktop/providers/like_provider.dart';
import 'package:scouttrack_desktop/models/like.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:image_picker/image_picker.dart';
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
  late ReviewProvider _reviewProvider;
  late PostProvider _postProvider;
  late CommentProvider _commentProvider;
  late LikeProvider _likeProvider;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRegistrations = 0;
  bool _isLoadingRegistrations = false;

  List<Review> _reviews = [];
  int _currentReviewPage = 1;
  int _reviewPageSize = 10;
  int _totalReviews = 0;
  double _averageRating = 0.0;
  bool _isLoadingReviews = false;
  String _reviewSearchQuery = '';
  String _reviewSortBy = 'createdat_desc';

  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _canCreatePost = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mapController = MapController();
    _activity = widget.activity;
    // _loadInitialData() is now called from didChangeDependencies() after providers are initialized
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

    // Check if AuthProvider is available (user is still logged in)
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Only initialize providers if authProvider is valid
      if (authProvider.isLoggedIn) {
        _activityProvider = ActivityProvider(authProvider);
        _activityRegistrationProvider = ActivityRegistrationProvider(
          authProvider,
        );
        _reviewProvider = ReviewProvider(authProvider);
        _postProvider = PostProvider(authProvider);
        _commentProvider = CommentProvider(authProvider);
        _likeProvider = LikeProvider(authProvider);

        // Load data only if we haven't loaded it yet and user is authenticated
        if (_activity != null && _role == null) {
          _loadInitialData();
        }
      }
    } catch (e) {
      // AuthProvider is not available (user logged out)
      print('AuthProvider not available: $e');
      return;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Check if we're still mounted and user is logged in
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        print('User not authenticated, skipping data load');
        return;
      }

      final role = await authProvider.getUserRole();
      final userId = await authProvider.getUserIdFromToken();

      // Check again if we're still mounted after async calls
      if (!mounted) return;

      setState(() {
        _role = role;
        _loggedInUserId = userId;
        _canStartOrFinish =
            role == 'Admin' ||
            (role == 'Troop' && userId == _activity?.troopId);
        _canManageRegistrations =
            role == 'Admin' ||
            (role == 'Troop' && userId == _activity?.troopId);
      });

      await _loadEquipment();
      await _loadRegistrations();
      await _loadReviews();
      await _loadPosts();
      await _checkCanCreatePost();
    } catch (e) {
      print('Error in _loadInitialData: $e');
      // Don't rethrow - this might happen during logout
    }
  }

  Future<void> _refreshActivity() async {
    try {
      final refreshedActivity = await _activityProvider.getById(_activity!.id);
      setState(() {
        _activity = refreshedActivity;
      });
    } catch (e) {
      print('Error refreshing activity: $e');
    }
  }

  Future<void> _loadEquipment() async {
    try {
      // Check if we're still mounted and user is logged in
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        print('User not authenticated, skipping equipment load');
        return;
      }

      final activityEquipmentProvider = ActivityEquipmentProvider(authProvider);
      final equipment = await activityEquipmentProvider.getByActivityId(
        _activity!.id,
      );

      // Check again if we're still mounted after async call
      if (!mounted) return;

      setState(() {
        _equipment = equipment;
      });
    } catch (e) {
      print('Error loading equipment: $e');
      // Don't rethrow - this might happen during logout
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
        'page': _currentPage - 1,
        'pageSize': _pageSize,
        'includeTotalCount': true,
      };

      if (_statusFilter != null) {
        filter['status'] = _statusFilter;
      }

      final registrations = await _activityRegistrationProvider.getByActivity(
        _activity!.id,
        filter: filter,
      );

      setState(() {
        _registrations = registrations.items ?? [];
        _totalRegistrations = registrations.totalCount ?? 0;
        _isLoadingRegistrations = false;
        _applyStatusFilter();
      });
    } catch (e) {
      setState(() {
        _isLoadingRegistrations = false;
      });
      print('Error loading registrations: $e');
    }
  }

  void _applyStatusFilter() {
    _filteredRegistrations = List.from(_registrations);
  }

  void _onStatusFilterChanged(int? value) {
    setState(() {
      _statusFilter = value;
      _currentPage = 1;
    });
    _loadRegistrations();
  }

  Future<void> _loadReviews({int? page}) async {
    if (page != null) {
      _currentReviewPage = page;
    }

    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final filter = <String, dynamic>{
        'page': _currentReviewPage - 1,
        'pageSize': _reviewPageSize,
        'includeTotalCount': true,
      };

      if (_reviewSearchQuery.isNotEmpty) {
        filter['fts'] = _reviewSearchQuery;
      }

      if (_reviewSortBy.isNotEmpty) {
        filter['orderBy'] = _reviewSortBy;
      }

      final reviews = await _reviewProvider.getByActivity(
        _activity!.id,
        filter: filter,
      );

      final allReviewsFilter = <String, dynamic>{
        'retrieveAll': true,
        'includeTotalCount': true,
      };

      final allReviews = await _reviewProvider.getByActivity(
        _activity!.id,
        filter: allReviewsFilter,
      );

      double averageRating = 0.0;
      if (allReviews.items != null && allReviews.items!.isNotEmpty) {
        double totalRating = allReviews.items!.fold(
          0.0,
          (sum, review) => sum + review.rating,
        );
        averageRating = totalRating / allReviews.items!.length;
      }

      setState(() {
        _reviews = reviews.items ?? [];
        _totalReviews = reviews.totalCount ?? 0;
        _averageRating = averageRating;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
      print('Error loading reviews: $e');
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final posts = await _postProvider.getByActivity(_activity!.id);
      setState(() {
        _posts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
      print('Error loading posts: $e');

      if (context.mounted) {
        String errorMessage = 'Nije moguće učitati objave.';

        if (e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup')) {
          errorMessage =
              'Nije moguće povezati se s serverom. Provjerite je li backend pokrenut.';
        } else if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          errorMessage = 'Niste autorizirani za pristup galeriji.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Galerija nije dostupna za ovu aktivnost.';
        } else if (e.toString().contains('500') ||
            e.toString().contains('Server side error')) {
          errorMessage =
              'Galerija je trenutno nedostupna. Pokušajte ponovo kasnije.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _checkCanCreatePost() async {
    if (_activity == null) {
      setState(() {
        _canCreatePost = false;
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userInfo = await authProvider.getCurrentUserInfo();

    if (userInfo == null) {
      setState(() {
        _canCreatePost = false;
      });
      return;
    }

    final userRole = userInfo['role'] as String?;
    final userId = userInfo['id'] as int?;

    setState(() {
      _canCreatePost = PermissionUtils.canCreatePost(
        userRole,
        userId,
        _activity!,
        _registrations,
      );
    });
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
              if (_activity!.activityState == 'FinishedActivityState')
                UIComponents.buildDetailRow(
                  'Broj učesnika',
                  _activity!.registrationCount.toString(),
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
    if (_activity?.activityState != 'FinishedActivityState') {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Galerija nije dostupna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Galerija je dostupna samo za završene aktivnosti.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Fotografije i objave mogu se dodavati nakon što se aktivnost završi.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Galerija (${_posts.length} objava)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_canCreatePost)
                ElevatedButton.icon(
                  onPressed: _showAddPostDialog,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Dodaj objavu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8055),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoadingPosts
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nema objava',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Napomena: Galerija je dostupna samo za završene aktivnosti.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () => _showPostDetails(post),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: post.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Image.network(
                                    post.images.first.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (post.images.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${post.images.length - 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
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

    if (_role == 'Admin') {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          tooltip: 'Obriši registraciju',
          onPressed: () => _onDeleteRegistration(registration),
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
        if (_activity?.activityState == 'FinishedActivityState') {
          await _refreshActivity();
        }
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
        if (_activity?.activityState == 'FinishedActivityState') {
          await _refreshActivity();
        }
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
        if (_activity?.activityState == 'FinishedActivityState') {
          await _refreshActivity();
        }
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

  Future<void> _onDeleteRegistration(ActivityRegistration registration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši registraciju'),
        content: Text(
          'Jeste li sigurni da želite obrisati registraciju za ${registration.memberName}?\n\n'
          'Ova akcija je nepovratna i obrisat će registraciju iz sustava.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityRegistrationProvider.delete(registration.id);
        if (_activity?.activityState == 'FinishedActivityState') {
          await _refreshActivity();
        }
        await _loadRegistrations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registracija za ${registration.memberName} je obrisana.',
            ),
            backgroundColor: Colors.red,
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prosječna ocjena: ${_averageRating.toStringAsFixed(1)}/5.0',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ukupno recenzija: $_totalReviews',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < _averageRating.floor()
                        ? Icons.star
                        : index < _averageRating
                        ? Icons.star_half
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Pretraži po imenu člana...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _reviewSearchQuery = value;
                    _currentReviewPage = 1;
                  });
                  _loadReviews();
                },
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _reviewSortBy,
              hint: const Text('Sortiraj'),
              items: const [
                DropdownMenuItem(
                  value: 'createdat_desc',
                  child: Text('Najnovije'),
                ),
                DropdownMenuItem(value: 'createdat', child: Text('Najstarije')),
                DropdownMenuItem(
                  value: 'rating_desc',
                  child: Text('Najbolje ocjene'),
                ),
                DropdownMenuItem(
                  value: 'rating',
                  child: Text('Najgore ocjene'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _reviewSortBy = value;
                    _currentReviewPage = 1;
                  });
                  _loadReviews();
                }
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
            child: _isLoadingReviews
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _reviews.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nema recenzija',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    review.memberName.isNotEmpty
                                        ? review.memberName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.memberName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ...List.generate(
                                            5,
                                            (starIndex) => Icon(
                                              starIndex < review.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${review.rating}/5',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd. MM. yyyy.',
                                      ).format(review.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (_role == 'Admin') ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            _onDeleteReview(review),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        tooltip: 'Obriši recenziju',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              review.content,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),

        if (_totalReviews > 0) ...[
          const SizedBox(height: 16),
          _buildReviewPaginationControls(),
        ],
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

  Widget _buildReviewPaginationControls() {
    final totalPages = (_totalReviews / _reviewPageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _currentReviewPage > 1
              ? () => _loadReviews(page: _currentReviewPage - 1)
              : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Prethodna'),
        ),
        Row(
          children: [
            if (totalPages <= 7) ...[
              for (int i = 1; i <= totalPages; i++)
                _buildReviewPageButton(i, i == _currentReviewPage),
            ] else ...[
              _buildReviewPageButton(1, _currentReviewPage == 1),
              if (_currentReviewPage > 3) const Text('...'),
              if (_currentReviewPage > 2)
                _buildReviewPageButton(_currentReviewPage - 1, false),
              _buildReviewPageButton(_currentReviewPage, true),
              if (_currentReviewPage < totalPages - 1)
                _buildReviewPageButton(_currentReviewPage + 1, false),
              if (_currentReviewPage < totalPages - 2) const Text('...'),
              _buildReviewPageButton(
                totalPages,
                _currentReviewPage == totalPages,
              ),
            ],
          ],
        ),
        TextButton.icon(
          onPressed: _currentReviewPage < totalPages
              ? () => _loadReviews(page: _currentReviewPage + 1)
              : null,
          label: const Text('Sljedeća'),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  Widget _buildReviewPageButton(int page, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isActive
            ? const Color(0xFF4F8055)
            : Colors.grey.shade300,
        child: TextButton(
          onPressed: isActive ? null : () => _loadReviews(page: page),
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

  Future<void> _onDeleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši recenziju'),
        content: Text(
          'Jeste li sigurni da želite obrisati recenziju od ${review.memberName}? Ova akcija je nepovratna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewProvider.delete(review.id);
        await _loadReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recenzija od ${review.memberName} je obrisana.'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Widget _buildActionButtons() {
    if (!_canStartOrFinish) {
      return const SizedBox.shrink();
    }

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

        await _refreshActivity();
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

  Future<void> _showAddPostDialog() async {
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<File> selectedImages = [];
    List<String> uploadedImageUrls = [];
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Dodaj novu objavu'),
              content: Container(
                constraints: const BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 500,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Podijeli svoje iskustvo i fotografije s ove aktivnosti.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: contentController,
                            decoration: const InputDecoration(
                              labelText: 'Opis objave (opcionalno)',
                              hintText: 'Napišite nešto o svom iskustvu...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            validator: (value) {
                              if (value != null && value.trim().length > 1000) {
                                return 'Opis može imati najviše 1000 karaktera';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Fotografije',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (selectedImages.length < 10)
                              TextButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    final bytes = await pickedFile
                                        .readAsBytes();
                                    final compressedBytes =
                                        await ImageUtils.compressImage(bytes);
                                    final compressedFile = File(
                                      pickedFile.path,
                                    );
                                    await compressedFile.writeAsBytes(
                                      compressedBytes,
                                    );
                                    setState(() {
                                      selectedImages.add(compressedFile);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Dodaj'),
                              )
                            else
                              Text(
                                'Maksimalno 10 fotografija',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (selectedImages.isNotEmpty) ...[
                          Container(
                            height: 120,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: selectedImages.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final image = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            image,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedImages.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${selectedImages.length}/10 fotografija',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (isUploading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text(
                            'Učitavanje fotografija...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Otkaži'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            if (selectedImages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Molimo odaberite barem jednu fotografiju.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              isUploading = true;
                            });

                            try {
                              for (final image in selectedImages) {
                                final imageUrl = await _postProvider
                                    .uploadImage(image);
                                uploadedImageUrls.add(imageUrl);
                              }

                              await _postProvider.createPost(
                                contentController.text.trim(),
                                _activity!.id,
                                uploadedImageUrls,
                              );

                              await _loadPosts();

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Objava je uspješno dodana!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                isUploading = false;
                              });
                              showErrorSnackbar(context, e);
                            }
                          }
                        },
                  child: const Text('Objavi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPostDetails(Post initialPost) async {
    final PageController pageController = PageController();
    int currentImageIndex = 0;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userInfo = await authProvider.getCurrentUserInfo();

    final postProvider = PostProvider(authProvider);
    final commentProvider = CommentProvider(authProvider);
    final likeProvider = LikeProvider(authProvider);

    bool canEdit = false;
    bool canDelete = false;
    bool isAdmin = false;

    if (userInfo != null) {
      final userRole = userInfo['role'] as String?;
      final userId = userInfo['id'] as int?;

      isAdmin = userRole == 'Admin';
      canEdit = PermissionUtils.canEditPost(userRole, userId, initialPost);
      canDelete = PermissionUtils.canDeletePost(
        userRole,
        userId,
        initialPost,
        _activity!,
      );
    }

    Post currentPost = initialPost;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLiked = currentPost.isLikedByCurrentUser;
            int likeCount = currentPost.likeCount;
            int commentCount = currentPost.commentCount;
            List<Comment> comments = List.from(currentPost.comments);

            final TextEditingController commentController =
                TextEditingController();
            final FocusNode commentFocusNode = FocusNode();

            Future<void> refreshPostData() async {
              try {
                final refreshedPosts = await postProvider.getByActivity(
                  _activity!.id,
                );
                final refreshedPost = refreshedPosts.firstWhere(
                  (p) => p.id == currentPost.id,
                );
                setState(() {
                  currentPost = refreshedPost;
                  isLiked = currentPost.isLikedByCurrentUser;
                  likeCount = currentPost.likeCount;
                  commentCount = currentPost.commentCount;
                  comments = List.from(currentPost.comments);
                });
              } catch (e) {
                print('Error refreshing post data: $e');
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          const Expanded(
                            child: Text(
                              'Detalji objave',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (canEdit)
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showEditPostDialog(currentPost);
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              tooltip: 'Uredi objavu',
                            ),
                          if (canDelete)
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showDeletePostDialog(currentPost);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              tooltip: 'Obriši objavu',
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentPost.createdByName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          currentPost.createdByTroopName ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatDate(currentPost.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (currentPost.content.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  currentPost.content,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),

                            if (currentPost.images.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: currentPost.images.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          currentImageIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final image = currentPost.images[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              image.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Navigation arrows - only show if there are multiple images
                                  if (currentPost.images.length > 1) ...[
                                    // Left arrow
                                    Positioned(
                                      left: 8,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed: currentImageIndex > 0
                                                ? () {
                                                    pageController.previousPage(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                : null,
                                            icon: const Icon(
                                              Icons.chevron_left,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Right arrow
                                    Positioned(
                                      right: 8,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed:
                                                currentImageIndex <
                                                    currentPost.images.length -
                                                        1
                                                ? () {
                                                    pageController.nextPage(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                : null,
                                            icon: const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Dots indicator
                              if (currentPost.images.length > 1)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      currentPost.images.length,
                                      (index) => Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index == currentImageIndex
                                              ? Colors.green
                                              : Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      if (isAdmin) return;
                                      setState(() {
                                        if (isLiked) {
                                          isLiked = false;
                                          likeCount--;
                                        } else {
                                          isLiked = true;
                                          likeCount++;
                                        }
                                      });

                                      await _onLikePost(
                                        currentPost,
                                        likeProvider: likeProvider,
                                        postProvider: postProvider,
                                      );
                                      await refreshPostData();
                                    },
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showLikesDialog(currentPost),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '$likeCount',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.comment_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed: null,
                                  ),
                                  Text(
                                    '$commentCount',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),

                            if (comments.isNotEmpty) ...[
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Komentari',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: comments
                                      .map(
                                        (comment) => _buildCommentItem(
                                          comment,
                                          refreshPostData,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],

                            if (!isAdmin) ...[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _buildCommentInput(
                                  currentPost,
                                  commentController,
                                  commentFocusNode,
                                  (String content) {
                                    setState(() {
                                      commentCount++;
                                      final optimisticComment = Comment(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        content: content,
                                        createdAt: DateTime.now(),
                                        postId: currentPost.id,
                                        createdById: 0,
                                        createdByName: 'You',
                                        createdByTroopName: null,
                                        createdByAvatarUrl: null,
                                        canEdit: true,
                                        canDelete: true,
                                      );
                                      comments.insert(0, optimisticComment);
                                    });
                                  },
                                  refreshPostData,
                                  commentProvider,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPostDialog(Post post) {
    final TextEditingController contentController = TextEditingController(
      text: post.content,
    );
    List<File> selectedImages = [];
    List<String> existingImageUrls = post.images
        .map((img) => img.imageUrl)
        .toList();
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Uredi objavu'),
              content: Container(
                constraints: const BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 500,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uredite sadržaj i fotografije objave.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: 'Opis objave (opciono)',
                            hintText: 'Napišite nešto o svojem iskustvu...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          validator: (value) {
                            if (value != null && value.trim().length > 1000) {
                              return 'Opis može imati najviše 1000 karaktera';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (existingImageUrls.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Postojeće fotografije',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: existingImageUrls.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final imageUrl = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              existingImageUrls.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          const Icon(Icons.photo_library, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Nove fotografije',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (existingImageUrls.length + selectedImages.length <
                              10)
                            TextButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (pickedFile != null) {
                                  final bytes = await pickedFile.readAsBytes();
                                  final compressedBytes =
                                      await ImageUtils.compressImage(bytes);
                                  final compressedFile = File(pickedFile.path);
                                  await compressedFile.writeAsBytes(
                                    compressedBytes,
                                  );
                                  setState(() {
                                    selectedImages.add(compressedFile);
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Dodaj'),
                            )
                          else
                            Text(
                              'Maksimalno 10 fotografija',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (selectedImages.isNotEmpty) ...[
                        Container(
                          height: 120,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedImages.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final image = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          image,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${existingImageUrls.length + selectedImages.length}/10 fotografija',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (existingImageUrls.isNotEmpty)
                          Text(
                            '(${existingImageUrls.length} postojećih + ${selectedImages.length} novih)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],

                      if (isUploading) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Učitavanje slika...'),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          // Check if there are any images left
                          if (existingImageUrls.isEmpty &&
                              selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Objava mora imati najmanje jednu fotografiju.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isUploading = true;
                          });

                          try {
                            List<String> newImageUrls = [];
                            for (final image in selectedImages) {
                              final imageUrl = await _postProvider.uploadImage(
                                image,
                              );
                              newImageUrls.add(imageUrl);
                            }

                            final allImageUrls = [
                              ...existingImageUrls,
                              ...newImageUrls,
                            ];

                            await _postProvider.updatePost(
                              post.id,
                              contentController.text.trim(),
                              allImageUrls,
                            );

                            await _loadPosts();

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Objava je uspješno ažurirana.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              isUploading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Greška: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Spremi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeletePostDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Obriši objavu'),
          content: const Text(
            'Jeste li sigurni da želite obrisati ovu objavu? Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _postProvider.deletePost(post.id);

                  await _loadPosts();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Objava je uspješno obrisana.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Greška: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentItem(
    Comment comment, [
    Future<void> Function()? onRefresh,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage:
                comment.createdByAvatarUrl != null &&
                    comment.createdByAvatarUrl!.isNotEmpty
                ? NetworkImage(comment.createdByAvatarUrl!)
                : null,
            child:
                comment.createdByAvatarUrl == null ||
                    comment.createdByAvatarUrl!.isEmpty
                ? Text(
                    comment.createdByName.isNotEmpty
                        ? comment.createdByName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.createdByName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (comment.createdByTroopName != null &&
                        comment.createdByTroopName!.isNotEmpty)
                      Text(
                        comment.createdByTroopName!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    const Spacer(),
                    Text(
                      formatDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
                if (comment.canEdit || comment.canDelete) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (comment.canEdit)
                        TextButton(
                          onPressed: () => _onEditComment(comment, onRefresh),
                          child: const Text(
                            'Uredi',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (comment.canEdit && comment.canDelete)
                        const SizedBox(width: 8),
                      if (comment.canDelete)
                        TextButton(
                          onPressed: () => _onDeleteComment(comment, onRefresh),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Obriši',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLikePost(
    Post post, {
    LikeProvider? likeProvider,
    PostProvider? postProvider,
  }) async {
    try {
      final likeProv = likeProvider ?? _likeProvider;
      final postProv = postProvider ?? _postProvider;

      if (post.isLikedByCurrentUser) {
        await likeProv.unlikePost(post.id);
      } else {
        await likeProv.likePost(post.id);
      }

      await _loadPosts();

      if (Navigator.of(context).canPop()) {
        final refreshedPosts = await postProv.getByActivity(_activity!.id);
        final refreshedPost = refreshedPosts.firstWhere((p) => p.id == post.id);
        post = refreshedPost;
      }
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  void _showLikesDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sviđanja (${post.likes.length})'),
          content: Container(
            width: 400,
            child: post.likes.isEmpty
                ? const Center(
                    child: Text(
                      'Nema sviđanja za ovu objavu.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: post.likes.length,
                    itemBuilder: (context, index) {
                      final like = post.likes[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              like.createdByAvatarUrl != null &&
                                  like.createdByAvatarUrl!.isNotEmpty
                              ? NetworkImage(like.createdByAvatarUrl!)
                              : null,
                          child:
                              like.createdByAvatarUrl == null ||
                                  like.createdByAvatarUrl!.isEmpty
                              ? Text(
                                  like.createdByName.isNotEmpty
                                      ? like.createdByName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(like.createdByName),
                        subtitle:
                            like.createdByTroopName != null &&
                                like.createdByTroopName!.isNotEmpty
                            ? Text(like.createdByTroopName!)
                            : null,
                        trailing: Text(
                          formatDate(like.likedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput(
    Post post,
    TextEditingController commentController,
    FocusNode commentFocusNode, [
    Function(String)? onOptimisticUpdate,
    Future<void> Function()? onRefreshPost,
    CommentProvider? commentProvider,
  ]) {
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: commentController,
              focusNode: commentFocusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Ostavi komentar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  final content = value.trim();

                  if (onOptimisticUpdate != null) {
                    onOptimisticUpdate(content);
                  }

                  commentController.clear();

                  await _submitComment(
                    post,
                    content,
                    commentController,
                    onOptimisticUpdate,
                    onRefreshPost,
                    commentProvider,
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () async {
            if (commentController.text.trim().isNotEmpty) {
              final content = commentController.text.trim();

              if (onOptimisticUpdate != null) {
                onOptimisticUpdate(content);
              }

              await _submitComment(
                post,
                content,
                commentController,
                onOptimisticUpdate,
                onRefreshPost,
                commentProvider,
              );
            }
          },
          icon: const Icon(Icons.send, color: Colors.green),
        ),
      ],
    );
  }

  Future<void> _submitComment(
    Post post,
    String content,
    TextEditingController controller, [
    Function(String)? onOptimisticUpdate,
    Future<void> Function()? onRefreshPost,
    CommentProvider? commentProvider,
  ]) async {
    if (onOptimisticUpdate != null) {
      onOptimisticUpdate(content);
    }

    try {
      final provider = commentProvider ?? _commentProvider;
      await provider.createComment(content, post.id);

      controller.clear();

      if (onRefreshPost != null) {
        await onRefreshPost();
      } else {
        await _loadPosts();
      }
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _onEditComment(
    Comment comment, [
    Future<void> Function()? onRefresh,
  ]) async {
    final contentController = TextEditingController(text: comment.content);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uredi komentar'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Komentar',
                    hintText: 'Uredite svoj komentar...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Komentar je obavezan';
                    }
                    if (value.trim().length > 1000) {
                      return 'Komentar može imati najviše 1000 karaktera';
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
                    await _commentProvider.updateComment(
                      comment.id,
                      contentController.text.trim(),
                    );

                    await _loadPosts();

                    if (onRefresh != null) {
                      await onRefresh();
                    }

                    Navigator.of(context).pop();
                  } catch (e) {
                    showErrorSnackbar(context, e);
                  }
                }
              },
              child: const Text('Spremi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDeleteComment(
    Comment comment, [
    Future<void> Function()? onRefresh,
  ]) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši komentar'),
        content: Text(
          'Jeste li sigurni da želite obrisati komentar od ${comment.createdByName}? Ova akcija je nepovratna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _commentProvider.deleteComment(comment.id);
        await _loadPosts();

        if (onRefresh != null) {
          await onRefresh();
        }
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }
}
