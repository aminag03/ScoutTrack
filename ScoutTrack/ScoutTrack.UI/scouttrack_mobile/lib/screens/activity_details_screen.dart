import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../layouts/master_screen.dart';
import '../models/activity.dart';
import '../models/activity_equipment.dart';
import '../models/troop.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/like.dart';
import '../models/member.dart';
import '../models/review.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import '../providers/troop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/activity_equipment_provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/like_provider.dart';
import '../providers/activity_registration_provider.dart';
import '../providers/member_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/review_forms.dart';
import 'troop_details_screen.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MapController _mapController;
  LatLng? _activityLocation;
  List<ActivityEquipment> _equipment = [];
  bool _isLoadingEquipment = false;

  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _canCreatePost = false;
  final ValueNotifier<List<Post>> _postsNotifier = ValueNotifier<List<Post>>(
    [],
  );

  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  double _averageRating = 0.0;
  Review? _myReview;
  bool _canCreateReview = false;

  Activity? _currentActivity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mapController = MapController();
    _currentActivity = widget.activity;

    if (_currentActivity!.latitude != 0 && _currentActivity!.longitude != 0) {
      _activityLocation = LatLng(
        _currentActivity!.latitude,
        _currentActivity!.longitude,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_activityLocation != null) {
          _mapController.move(_activityLocation!, 15.0);
        }
      });
    }
    _loadActivity();
    _loadEquipment();
    _loadPosts();
    _checkCanCreatePost();
    _loadReviews();
    _checkCanCreateReview();
  }

  Future<void> _loadActivity() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = ActivityProvider(authProvider);
      final freshActivity = await activityProvider.getById(widget.activity.id);

      if (mounted) {
        setState(() {
          _currentActivity = freshActivity;
        });
      }
    } catch (e) {
      print('Error loading activity: $e');
    }
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _isLoadingEquipment = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final equipmentProvider = ActivityEquipmentProvider(authProvider);
      final equipment = await equipmentProvider.getByActivityId(
        widget.activity.id,
      );

      if (mounted) {
        setState(() {
          _equipment = equipment;
          _isLoadingEquipment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEquipment = false;
        });
      }
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = PostProvider(authProvider);
      final posts = await postProvider.getByActivity(widget.activity.id);

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
        _postsNotifier.value = posts;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _checkCanCreatePost() async {
    final activity = _currentActivity ?? widget.activity;

    if (activity.activityState != 'FinishedActivityState') {
      setState(() {
        _canCreatePost = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo != null) {
        final registrationProvider = ActivityRegistrationProvider(authProvider);
        final registrations = await registrationProvider.getMemberRegistrations(
          memberId: userInfo['id'],
          statuses: [3], // Completed status
          retrieveAll: true,
        );

        final hasCompletedRegistration =
            registrations.items?.any((reg) => reg.activityId == activity.id) ??
            false;

        if (mounted) {
          setState(() {
            _canCreatePost = hasCompletedRegistration;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canCreatePost = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reviewProvider = ReviewProvider(authProvider);

      final reviewsResult = await reviewProvider.getByActivity(
        widget.activity.id,
        filter: {'retrieveAll': true},
      );

      double averageRating = 0.0;
      if (reviewsResult.items != null && reviewsResult.items!.isNotEmpty) {
        double totalRating = reviewsResult.items!.fold(
          0.0,
          (sum, review) => sum + review.rating,
        );
        averageRating = totalRating / reviewsResult.items!.length;
      }

      Review? myReview;
      final currentUserId = await authProvider.getUserIdFromToken();
      if (currentUserId != null && reviewsResult.items != null) {
        try {
          myReview = reviewsResult.items!.firstWhere(
            (review) => review.memberId == currentUserId,
          );
        } catch (e) {
          myReview = null;
        }
      }

      if (mounted) {
        setState(() {
          _reviews = reviewsResult.items ?? [];
          _averageRating = averageRating;
          _myReview = myReview;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _checkCanCreateReview() async {
    final activity = _currentActivity ?? widget.activity;

    if (activity.activityState != 'FinishedActivityState') {
      setState(() {
        _canCreateReview = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo != null) {
        final registrationProvider = ActivityRegistrationProvider(authProvider);
        final registrations = await registrationProvider.getMemberRegistrations(
          memberId: userInfo['id'],
          statuses: [3], // Completed status
          retrieveAll: true,
        );

        final hasCompletedRegistration =
            registrations.items?.any((reg) => reg.activityId == activity.id) ??
            false;

        if (mounted) {
          setState(() {
            _canCreateReview = hasCompletedRegistration && _myReview == null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canCreateReview = false;
        });
      }
    }
  }

  void _showCreateReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateReviewForm(
        activityId: widget.activity.id,
        onReviewCreated: () {
          Navigator.pop(context);
          _loadReviews();
          _checkCanCreateReview();
        },
      ),
    );
  }

  void _showEditReviewDialog(Review review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditReviewForm(
        review: review,
        onReviewUpdated: () {
          Navigator.pop(context);
          _loadReviews();
          _checkCanCreateReview();
        },
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje recenzije'),
        content: const Text(
          'Da li ste sigurni da želite obrisati ovu recenziju?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reviewProvider = ReviewProvider(authProvider);

      await reviewProvider.deleteReview(review.id);

      if (mounted) {
        await _loadReviews();
        await _checkCanCreateReview();

        SnackBarUtils.showSuccessSnackBar(
          'Recenzija je uspješno obrisana',
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postsNotifier.dispose();
    super.dispose();
  }

  String _getPostPlural(int count) {
    if (count == 0) return 'objava';
    if (count == 1) return 'objava';
    if (count >= 2 && count <= 4) return 'objave';
    if (count >= 5 && count <= 20) return 'objava';
    if (count >= 21) {
      int lastDigit = count % 10;
      if (lastDigit >= 2 && lastDigit <= 4) return 'objave';
      return 'objava';
    }
    return 'objava';
  }

  String _getLikePlural(int count) {
    if (count == 0) return 'sviđanja';
    if (count == 1) return 'sviđanje';
    if (count == 11) return 'sviđanja';
    if (count >= 2 && count <= 4) return 'sviđanja';
    if (count >= 5 && count <= 20) return 'sviđanja';
    if (count >= 21) {
      int lastDigit = count % 10;
      if (lastDigit == 1) return 'sviđanje';
      return 'sviđanja';
    }
    return 'sviđanja';
  }

  String _getCommentPlural(int count) {
    if (count == 0) return 'komentara';
    if (count == 1) return 'komentar';
    if (count == 11) return 'komentara';
    if (count >= 2 && count <= 4) return 'komentara';
    if (count >= 5 && count <= 20) return 'komentara';
    if (count >= 21) {
      int lastDigit = count % 10;
      if (lastDigit == 1) return 'komentar';
      return 'komentara';
    }
    return 'komentara';
  }

  String _getReviewPlural(int count) {
    if (count == 0) return 'recenzija';
    if (count == 1) return 'recenzija';
    if (count >= 2 && count <= 4) return 'recenzije';
    if (count >= 5 && count <= 20) return 'recenzija';
    if (count >= 21) {
      int lastDigit = count % 10;
      if (lastDigit >= 2 && lastDigit <= 4) return 'recenzije';
      return 'recenzija';
    }
    return 'recenzija';
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: (_currentActivity ?? widget.activity).title,
      selectedIndex: -1,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: Column(
          children: [
            _buildTabBar(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildGalleryTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Detalji'),
              Tab(text: 'Galerija'),
              Tab(text: 'Recenzije'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),

          _buildQuickInfoCards(),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),

                  _buildKeyInfoGrid(),
                  const SizedBox(height: 24),

                  if (widget.activity.activityState !=
                      'FinishedActivityState') ...[
                    _buildEquipmentSection(),
                    const SizedBox(height: 24),
                  ],

                  if (widget.activity.summary.isNotEmpty &&
                      widget.activity.activityState == 'FinishedActivityState')
                    _buildSummarySection(),
                ],
              ),
            ),
          ),

          if (_activityLocation != null) ...[
            const SizedBox(height: 16),
            _buildMapSection(),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    if (widget.activity.activityState != 'FinishedActivityState') {
      return Container(
        color: const Color(0xFFF5F5DC),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.lock, size: 48, color: Colors.orange[400]),
              ),
              const SizedBox(height: 24),
              Text(
                'Galerija nije dostupna',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Galerija će biti dostupna nakon završetka aktivnosti',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF5F5DC),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.photo_library, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Galerija (${_posts.length} ${_getPostPlural(_posts.length)})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_canCreatePost)
                  Container(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: _showCreatePostDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Objavi fotografije',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _isLoadingPosts
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? _buildEmptyGallery()
                : _buildPostsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.photo_library, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Nema ${_getPostPlural(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostThumbnail(post);
      },
    );
  }

  Widget _buildPostThumbnail(Post post) {
    return GestureDetector(
      onTap: () => _showPostDetails(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: post.images.isNotEmpty
                    ? Image.network(
                        UrlUtils.buildImageUrl(post.images.first.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                      ),
              ),

              if (post.images.length > 1)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 10, color: Colors.red[300]),
                      const SizedBox(width: 2),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCardWithState(Post post, StateSetter setModalState) {
    final currentPost = _posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple[100],
                  backgroundImage:
                      currentPost.createdByAvatarUrl != null &&
                          currentPost.createdByAvatarUrl!.isNotEmpty
                      ? NetworkImage(
                          UrlUtils.buildImageUrl(
                            currentPost.createdByAvatarUrl!,
                          ),
                        )
                      : null,
                  child:
                      currentPost.createdByAvatarUrl == null ||
                          currentPost.createdByAvatarUrl!.isEmpty
                      ? Text(
                          currentPost.createdByName.isNotEmpty
                              ? currentPost.createdByName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  onBackgroundImageError:
                      currentPost.createdByAvatarUrl != null &&
                          currentPost.createdByAvatarUrl!.isNotEmpty
                      ? (exception, stackTrace) {
                          // Fallback to text avatar if image fails to load
                        }
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPost.createdByName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (currentPost.createdByTroopName != null)
                        Text(
                          'Odred izviđača "${currentPost.createdByTroopName}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (currentPost.images.isNotEmpty)
            _buildImageCarousel(currentPost.images),

          if (currentPost.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentPost.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _toggleLikeInModal(currentPost, setModalState),
                      child: Icon(
                        currentPost.isLikedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentPost.isLikedByCurrentUser
                            ? Colors.red
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showPostLikes(currentPost),
                      child: Text(
                        '${currentPost.likeCount} ${_getLikePlural(currentPost.likeCount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showPostComments(currentPost),
                      child: Icon(
                        Icons.comment_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showPostComments(currentPost),
                      child: Text(
                        '${currentPost.commentCount} ${_getCommentPlural(currentPost.commentCount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (currentPost.comments.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ...currentPost.comments
                      .take(2)
                      .map((comment) => _buildCommentPreview(comment)),
                  if (currentPost.comments.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: GestureDetector(
                        onTap: () => _showPostComments(currentPost),
                        child: Text(
                          'Prikaži sve komentare',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return FutureBuilder<Member?>(
                      future: _getCurrentUserMember(authProvider),
                      builder: (context, snapshot) {
                        final member = snapshot.data;
                        final firstName = member?.firstName;
                        final avatarUrl = member?.profilePictureUrl;

                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.purple[100],
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(UrlUtils.buildImageUrl(avatarUrl))
                              : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                  firstName?.isNotEmpty == true
                                      ? firstName![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          onBackgroundImageError:
                              avatarUrl != null && avatarUrl.isNotEmpty
                              ? (exception, stackTrace) {
                                  // Fallback to text avatar if image fails to load
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCommentInput(currentPost, setModalState),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_comment_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ostavi komentar...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Member?> _getCurrentUserMember(AuthProvider authProvider) async {
    try {
      final userId = await authProvider.getUserIdFromToken();
      if (userId == null) return null;

      final memberProvider = MemberProvider(authProvider);
      return await memberProvider.getById(userId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getMemberProfilePicture(int memberId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = MemberProvider(authProvider);
      final member = await memberProvider.getById(memberId);
      return member.profilePictureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _canEditPost(Post post) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = await authProvider.getUserIdFromToken();
      return currentUserId != null && currentUserId == post.createdById;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _canEditComment(Comment comment) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = await authProvider.getUserIdFromToken();
      final canEdit =
          currentUserId != null && currentUserId == comment.createdById;

      return canEdit;
    } catch (e) {
      return false;
    }
  }

  Widget _buildImageCarousel(List<PostImage> images) {
    return _ImageCarouselWidget(images: images);
  }

  Widget _buildCommentPreview(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.purple[100],
            backgroundImage:
                comment.createdByAvatarUrl != null &&
                    comment.createdByAvatarUrl!.isNotEmpty
                ? NetworkImage(
                    UrlUtils.buildImageUrl(comment.createdByAvatarUrl!),
                  )
                : null,
            child:
                comment.createdByAvatarUrl == null ||
                    comment.createdByAvatarUrl!.isEmpty
                ? Text(
                    comment.createdByName.isNotEmpty
                        ? comment.createdByName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
            onBackgroundImageError:
                comment.createdByAvatarUrl != null &&
                    comment.createdByAvatarUrl!.isNotEmpty
                ? (exception, stackTrace) {
                    // Fallback to text avatar if image fails to load
                  }
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.createdByName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Container(
      color: const Color(0xFFF5F5DC),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    if (_canCreateReview || _myReview != null)
                      Container(
                        height: 36,
                        child: Tooltip(
                          message: _myReview != null
                              ? 'Već ste ostavili recenziju za ovu aktivnost.'
                              : '',
                          child: ElevatedButton.icon(
                            onPressed: _canCreateReview
                                ? _showCreateReviewDialog
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canCreateReview
                                  ? Colors.green[600]
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            icon: Icon(
                              _canCreateReview ? Icons.add : Icons.check,
                              size: 16,
                            ),
                            label: Text(
                              _canCreateReview
                                  ? 'Ostavi recenziju'
                                  : 'Recenzija ostavljena',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_reviews.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          if (index < _averageRating.floor()) {
                            return Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 28,
                            );
                          } else if (index < _averageRating) {
                            return Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 28,
                            );
                          } else {
                            return Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 28,
                            );
                          }
                        }),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_averageRating.toStringAsFixed(1)} (${_reviews.length} ${_getReviewPlural(_reviews.length)})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: _isLoadingReviews
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                ? _buildEmptyReviews()
                : _buildReviewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.star_rate, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Nema recenzija',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    final isMyReview = _myReview?.id == review.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _getMemberProfilePicture(review.memberId),
                  builder: (context, snapshot) {
                    final profilePictureUrl = snapshot.data;

                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.purple[100],
                      backgroundImage:
                          profilePictureUrl != null &&
                              profilePictureUrl.isNotEmpty
                          ? NetworkImage(
                              UrlUtils.buildImageUrl(profilePictureUrl),
                            )
                          : null,
                      child:
                          profilePictureUrl == null || profilePictureUrl.isEmpty
                          ? Text(
                              review.memberName.isNotEmpty
                                  ? review.memberName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.purple[700],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                      onBackgroundImageError:
                          profilePictureUrl != null &&
                              profilePictureUrl.isNotEmpty
                          ? (exception, stackTrace) {
                              // Fallback to text avatar if image fails to load
                            }
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.memberName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _formatDateTime(review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (isMyReview)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _showEditReviewDialog(review),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteReview(review),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),

            const SizedBox(height: 12),

            Text(
              review.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.activity.imagePath.isNotEmpty
                ? Image.network(
                    UrlUtils.buildImageUrl(widget.activity.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      transform: Matrix4.translationValues(0, -40, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.play_arrow,
              title: 'Početak',
              value: widget.activity.startTime != null
                  ? '${DateFormat('dd.MM.yyyy').format(widget.activity.startTime!)}\n${DateFormat('HH:mm').format(widget.activity.startTime!)}'
                  : 'N/A',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.stop,
              title: 'Kraj',
              value: widget.activity.endTime != null
                  ? '${DateFormat('dd.MM.yyyy').format(widget.activity.endTime!)}\n${DateFormat('HH:mm').format(widget.activity.endTime!)}'
                  : 'N/A',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.payments,
              title: 'Kotizacija',
              value: widget.activity.fee > 0
                  ? '${widget.activity.fee.toStringAsFixed(0)} KM'
                  : 'Besplatno',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.activity.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.group, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: _navigateToTroopDetails,
                child: Text(
                  'Odred izviđača "${widget.activity.troopName}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 12),

        _buildActivityStateBadge(),
      ],
    );
  }

  Widget _buildKeyInfoGrid() {
    return Column(
      children: [
        if (widget.activity.description.isNotEmpty) ...[
          _buildDescriptionSection(),
          const SizedBox(height: 24),
        ],

        _buildInfoCard(
          icon: Icons.category,
          title: 'Tip aktivnosti',
          content: widget.activity.activityTypeName,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),

        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Lokacija',
          content: widget.activity.locationName,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),

        _buildRegistrationStatusCard(),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info, color: Colors.amber[700], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Rezime',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Text(
            widget.activity.summary,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description, color: Colors.teal[700], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Opis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.2)),
          ),
          child: Text(
            widget.activity.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.map, color: Colors.red[600], size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lokacija na mapi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _activityLocation!,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.flingAnimation,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.scouttrack_mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _activityLocation!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nema slike',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToTroopDetails() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final troopProvider = TroopProvider(authProvider);

      Troop? troop;

      if (widget.activity.troopId > 0) {
        troop = await troopProvider.getById(widget.activity.troopId);
      } else {
        final troopResult = await troopProvider.get(
          filter: {"RetrieveAll": true},
        );

        if (troopResult.items != null && troopResult.items!.isNotEmpty) {
          try {
            troop = troopResult.items!.firstWhere(
              (t) => t.name == widget.activity.troopName,
            );
          } catch (e) {
            troop = troopResult.items!.firstWhere(
              (t) =>
                  t.name.toLowerCase().contains(
                    widget.activity.troopName.toLowerCase(),
                  ) ||
                  widget.activity.troopName.toLowerCase().contains(
                    t.name.toLowerCase(),
                  ),
              orElse: () => throw Exception(
                'Troop "${widget.activity.troopName}" not found',
              ),
            );
          }
        } else {
          throw Exception('No troops available');
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TroopDetailsScreen(troop: troop!),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.build, color: Colors.purple[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Preporučena oprema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingEquipment)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_equipment.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nema preporučene opreme za ovu aktivnost',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._equipment.map((equipment) => _buildEquipmentItem(equipment)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEquipmentItem(ActivityEquipment equipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.purple[600],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.equipmentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (equipment.equipmentDescription.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    equipment.equipmentDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  Widget _buildActivityStateBadge() {
    String stateText;
    Color stateColor;
    IconData stateIcon;

    switch (widget.activity.activityState) {
      case 'RegistrationsOpenActivityState':
        stateText = 'Prijave otvorene';
        stateColor = Colors.green;
        stateIcon = Icons.lock_open;
        break;
      case 'RegistrationsClosedActivityState':
        stateText = 'Prijave zatvorene';
        stateColor = Colors.orange;
        stateIcon = Icons.lock;
        break;
      case 'FinishedActivityState':
        stateText = 'Završena';
        stateColor = Colors.blue;
        stateIcon = Icons.check_circle;
        break;
      default:
        stateText = 'Nepoznato stanje';
        stateColor = Colors.grey;
        stateIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stateColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stateIcon, size: 16, color: stateColor),
          const SizedBox(width: 6),
          Text(
            stateText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: stateColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationStatusCard() {
    final activity = _currentActivity ?? widget.activity;

    if (activity.activityState == 'FinishedActivityState') {
      return _buildInfoCard(
        icon: Icons.people,
        title: 'Broj prisutnih',
        content: '${activity.registrationCount} prisutnih',
        color: Colors.green,
      );
    }

    if (activity.activityState == 'RegistrationsOpenActivityState' ||
        activity.activityState == 'RegistrationsClosedActivityState') {
      return Column(
        children: [
          _buildInfoCard(
            icon: Icons.pending_actions,
            title: 'Prijave na čekanju',
            content: '${activity.pendingRegistrationCount} prijava',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.check_circle,
            title: 'Odobrene prijave',
            content: '${activity.approvedRegistrationCount} prijava',
            color: Colors.blue,
          ),
        ],
      );
    }

    return _buildInfoCard(
      icon: Icons.people,
      title: 'Broj prijava',
      content: '${activity.registrationCount} prijava',
      color: Colors.purple,
    );
  }

  Future<void> _toggleLikeInModal(Post post, StateSetter setModalState) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final likeProvider = LikeProvider(authProvider);

      setState(() {
        final postIndex = _posts.indexWhere((p) => p.id == post.id);
        if (postIndex != -1) {
          _posts[postIndex] = Post(
            id: post.id,
            content: post.content,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            activityId: post.activityId,
            activityTitle: post.activityTitle,
            createdById: post.createdById,
            createdByName: post.createdByName,
            createdByTroopName: post.createdByTroopName,
            createdByAvatarUrl: post.createdByAvatarUrl,
            images: post.images,
            likeCount: post.isLikedByCurrentUser
                ? post.likeCount - 1
                : post.likeCount + 1,
            commentCount: post.commentCount,
            isLikedByCurrentUser: !post.isLikedByCurrentUser,
            likes: post.likes,
            comments: post.comments,
          );
        }
      });

      setModalState(() {});

      if (post.isLikedByCurrentUser) {
        await likeProvider.unlikePost(post.id);
      } else {
        await likeProvider.likePost(post.id);
      }

      if (mounted) {
        _loadPosts();
      }
    } catch (e) {
      if (mounted) {
        _loadPosts();
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  void _showPostDetails(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailsBottomSheet(post),
    );
  }

  Widget _buildPostDetailsBottomSheet(Post post) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return ValueListenableBuilder<List<Post>>(
          valueListenable: _postsNotifier,
          builder: (context, posts, child) {
            final currentPost = posts.firstWhere(
              (p) => p.id == post.id,
              orElse: () => post,
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Spacer(),
                        FutureBuilder<bool>(
                          future: _canEditPost(post),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _editPost(currentPost, setModalState),
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue[600],
                                  ),
                                  IconButton(
                                    onPressed: () => _deletePost(currentPost),
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red[600],
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildPostCardWithState(
                        currentPost,
                        setModalState,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostLikes(Post post) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final likeProvider = LikeProvider(authProvider);
      final freshLikes = await likeProvider.getByPost(post.id);

      final updatedPost = Post(
        id: post.id,
        content: post.content,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        activityId: post.activityId,
        activityTitle: post.activityTitle,
        createdById: post.createdById,
        createdByName: post.createdByName,
        createdByTroopName: post.createdByTroopName,
        createdByAvatarUrl: post.createdByAvatarUrl,
        images: post.images,
        likeCount: post.likeCount,
        commentCount: post.commentCount,
        isLikedByCurrentUser: post.isLikedByCurrentUser,
        likes: freshLikes,
        comments: post.comments,
      );

      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = updatedPost;
        }
      });

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildLikesBottomSheet(updatedPost),
        );
      }
    } catch (e) {
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildLikesBottomSheet(post),
        );
      }
    }
  }

  Widget _buildLikesBottomSheet(Post post) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Sviđanja (${post.likeCount})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: post.likes.length,
              itemBuilder: (context, index) {
                final like = post.likes[index];
                return _buildLikeItem(like);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeItem(Like like) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.purple[100],
            backgroundImage:
                like.createdByAvatarUrl != null &&
                    like.createdByAvatarUrl!.isNotEmpty
                ? NetworkImage(UrlUtils.buildImageUrl(like.createdByAvatarUrl!))
                : null,
            child:
                like.createdByAvatarUrl == null ||
                    like.createdByAvatarUrl!.isEmpty
                ? Text(
                    like.createdByName.isNotEmpty
                        ? like.createdByName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : null,
            onBackgroundImageError:
                like.createdByAvatarUrl != null &&
                    like.createdByAvatarUrl!.isNotEmpty
                ? (exception, stackTrace) {
                    // Fallback to text avatar if image fails to load
                  }
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  like.createdByName.isNotEmpty
                      ? like.createdByName
                      : (like.createdByTroopName?.isNotEmpty == true
                            ? like.createdByTroopName!
                            : 'Nepoznat korisnik'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (like.createdByTroopName != null &&
                    like.createdByTroopName != like.createdByName)
                  Text(
                    'Odred izviđača "${like.createdByTroopName}"',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Text(
            _formatDateTime(like.likedAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showPostComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsBottomSheet(post),
    );
  }

  Widget _buildCommentsBottomSheet(Post post) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        final currentPost = _posts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Komentari (${currentPost.commentCount})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: currentPost.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nema komentara',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Budite prvi koji će komentarisati',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentPost.comments.length,
                        itemBuilder: (context, index) {
                          final comment = currentPost.comments[index];
                          return _buildCommentItem(
                            comment,
                            currentPost,
                            setModalState,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(
    Comment comment,
    Post post,
    StateSetter setModalState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.purple[100],
            backgroundImage:
                comment.createdByAvatarUrl != null &&
                    comment.createdByAvatarUrl!.isNotEmpty
                ? NetworkImage(
                    UrlUtils.buildImageUrl(comment.createdByAvatarUrl!),
                  )
                : null,
            child:
                comment.createdByAvatarUrl == null ||
                    comment.createdByAvatarUrl!.isEmpty
                ? Text(
                    comment.createdByName.isNotEmpty
                        ? comment.createdByName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : null,
            onBackgroundImageError:
                comment.createdByAvatarUrl != null &&
                    comment.createdByAvatarUrl!.isNotEmpty
                ? (exception, stackTrace) {
                    // Fallback to text avatar if image fails to load
                  }
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.createdByName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    FutureBuilder<bool>(
                      future: _canEditComment(comment),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _editComment(comment, post, setModalState),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteComment(comment, post),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(comment.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(Comment comment, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje komentara'),
        content: const Text(
          'Da li ste sigurni da želite obrisati ovaj komentar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final commentProvider = CommentProvider(authProvider);

      await commentProvider.deleteComment(comment.id);

      if (mounted) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            final updatedComments = List<Comment>.from(post.comments)
              ..removeWhere((c) => c.id == comment.id);

            final updatedPost = Post(
              id: post.id,
              content: post.content,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              activityId: post.activityId,
              activityTitle: post.activityTitle,
              createdById: post.createdById,
              createdByName: post.createdByName,
              createdByTroopName: post.createdByTroopName,
              createdByAvatarUrl: post.createdByAvatarUrl,
              images: post.images,
              likeCount: post.likeCount,
              commentCount: post.commentCount - 1,
              isLikedByCurrentUser: post.isLikedByCurrentUser,
              likes: post.likes,
              comments: updatedComments,
            );
            _posts[index] = updatedPost;
          }
        });
        _postsNotifier.value = List.from(_posts);

        Navigator.pop(context);

        SnackBarUtils.showSuccessSnackBar(
          'Komentar je uspješno obrisan',
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _editComment(
    Comment comment,
    Post post,
    StateSetter setModalState,
  ) async {
    try {
      final currentPost = _posts.firstWhere(
        (p) => p.id == post.id,
        orElse: () => post,
      );

      final currentComment = currentPost.comments.firstWhere(
        (c) => c.id == comment.id,
        orElse: () => comment,
      );

      await _showEditCommentDialog(currentComment, currentPost, setModalState);
    } catch (e) {
      await _showEditCommentDialog(comment, post, setModalState);
    }
  }

  Future<void> _showEditCommentDialog(
    Comment comment,
    Post post,
    StateSetter setModalState,
  ) async {
    final contentController = TextEditingController(text: comment.content);
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Uredi komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 200,
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: TextField(
                          controller: contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Uredi komentar...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.purple[400]!,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${contentController.text.length}/500',
                            style: TextStyle(
                              fontSize: 12,
                              color: contentController.text.length > 500
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                          if (contentController.text.length > 500)
                            Text(
                              'Prekoračeno ograničenje',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Otkaži',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ||
                                contentController.text.trim().isEmpty ||
                                contentController.text.length > 1000
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await _updateComment(
                                  comment,
                                  post,
                                  contentController.text.trim(),
                                  setModalState,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Ažuriraj',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
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

  Future<void> _updateComment(
    Comment comment,
    Post post,
    String content,
    StateSetter setModalState,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = await authProvider.getUserIdFromToken();

      if (currentUserId != comment.createdById) {
        if (mounted) {
          SnackBarUtils.showErrorSnackBar(
            'Nemate dozvolu da uređujete ovaj komentar',
            context: context,
          );
        }
        return;
      }

      final commentProvider = CommentProvider(authProvider);

      await commentProvider.updateComment(comment.id, content);

      if (mounted) {
        setState(() {
          final postIndex = _posts.indexWhere((p) => p.id == post.id);
          if (postIndex != -1) {
            final updatedComments = List<Comment>.from(
              _posts[postIndex].comments,
            );
            final commentIndex = updatedComments.indexWhere(
              (c) => c.id == comment.id,
            );
            if (commentIndex != -1) {
              updatedComments[commentIndex] = Comment(
                id: comment.id,
                content: content,
                createdAt: comment.createdAt,
                updatedAt: DateTime.now(),
                postId: comment.postId,
                createdById: comment.createdById,
                createdByName: comment.createdByName,
                createdByTroopName: comment.createdByTroopName,
                createdByAvatarUrl: comment.createdByAvatarUrl,
              );
            }

            _posts[postIndex] = Post(
              id: _posts[postIndex].id,
              content: _posts[postIndex].content,
              createdAt: _posts[postIndex].createdAt,
              updatedAt: _posts[postIndex].updatedAt,
              activityId: _posts[postIndex].activityId,
              activityTitle: _posts[postIndex].activityTitle,
              createdById: _posts[postIndex].createdById,
              createdByName: _posts[postIndex].createdByName,
              createdByTroopName: _posts[postIndex].createdByTroopName,
              createdByAvatarUrl: _posts[postIndex].createdByAvatarUrl,
              images: _posts[postIndex].images,
              likeCount: _posts[postIndex].likeCount,
              commentCount: _posts[postIndex].commentCount,
              isLikedByCurrentUser: _posts[postIndex].isLikedByCurrentUser,
              likes: _posts[postIndex].likes,
              comments: updatedComments,
            );
          }
        });
        _postsNotifier.value = List.from(_posts);

        setModalState(() {});

        Navigator.pop(context);

        SnackBarUtils.showSuccessSnackBar(
          'Komentar je uspješno ažuriran',
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _submitComment(
    Post post,
    String content,
    StateSetter setModalState,
  ) async {
    if (content.trim().isEmpty) return;

    if (content.length > 500) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(
          'Komentar može imati maksimalno 500 karaktera',
          context: context,
        );
      }
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final commentProvider = CommentProvider(authProvider);

      await commentProvider.createComment(content.trim(), post.id);

      await _loadPosts();

      if (mounted) {
        setModalState(() {
          // Force rebuild to get fresh data from _posts list
        });
        
        SnackBarUtils.showSuccessSnackBar(
          'Komentar je uspješno dodan',
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        _loadPosts();
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  void _showCommentInput(Post post, StateSetter setModalState) {
    final controller = TextEditingController();
    bool isDisposed = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          if (!isDisposed) {
            controller.addListener(() {
              if (!isDisposed && context.mounted) {
                setState(() {});
              }
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Dodaj komentar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          isDisposed = true;
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Napišite komentar...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            autofocus: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${controller.text.length}/500',
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.text.length > 500
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            isDisposed = true;
                            Navigator.pop(context);
                          },
                          child: const Text('Otkaži'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              controller.text.trim().isEmpty ||
                                  controller.text.length > 500
                              ? null
                              : () async {
                                  final commentText = controller.text;
                                  isDisposed = true;
                                  Navigator.pop(context);
                                  if (context.mounted) {
                                    await _submitComment(
                                      post,
                                      commentText,
                                      setModalState,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pošalji'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreatePostBottomSheet(),
    );
  }

  Widget _buildCreatePostBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: CreatePostForm(
        activity: widget.activity,
        onPostCreated: () {
          Navigator.pop(context);
          _loadPosts();
        },
      ),
    );
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje objave'),
        content: const Text('Da li ste sigurni da želite obrisati ovu objavu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = PostProvider(authProvider);

      await postProvider.deletePost(post.id);

      if (mounted) {
        await _loadPosts();
        Navigator.pop(context);

        SnackBarUtils.showSuccessSnackBar(
          'Objava je uspješno obrisana',
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _editPost(Post post, StateSetter setModalState) async {
    final currentPost = _posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );
    await _showEditPostDialog(currentPost, setModalState);
  }

  Future<void> _showEditPostDialog(Post post, StateSetter setModalState) async {
    final contentController = TextEditingController(text: post.content);
    List<String> currentImageUrls = post.images
        .map((img) => img.imageUrl)
        .toList();
    List<String> selectedImages = [];
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Uredi objavu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: contentController,
                              maxLines: 5,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'Dodajte opis objave...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.purple[400]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${contentController.text.length}/1000',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: contentController.text.length > 1000
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                                if (contentController.text.length > 1000)
                                  Text(
                                    'Prekoračeno ograničenje',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Fotografije',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (currentImageUrls.isNotEmpty) ...[
                              Text(
                                'Trenutne fotografije:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: currentImageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                UrlUtils.buildImageUrl(
                                                  currentImageUrls[index],
                                                ),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 30,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  currentImageUrls.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[600],
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
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            Text(
                              'Nove fotografije:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (selectedImages.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                File(selectedImages[index]),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 30,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedImages.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[600],
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
                                  },
                                ),
                              ),

                            if (currentImageUrls.isNotEmpty ||
                                selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${currentImageUrls.length + selectedImages.length}/10 fotografija',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (currentImageUrls.isNotEmpty &&
                                  selectedImages.isNotEmpty)
                                Text(
                                  '(${currentImageUrls.length} postojećih + ${selectedImages.length} novih)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],

                            const SizedBox(height: 16),

                            if (currentImageUrls.length +
                                    selectedImages.length <
                                10)
                              GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final pickedFiles = await picker
                                      .pickMultiImage();
                                  if (pickedFiles.isNotEmpty) {
                                    setState(() {
                                      final remainingSlots =
                                          10 -
                                          currentImageUrls.length -
                                          selectedImages.length;
                                      final filesToAdd = pickedFiles
                                          .take(remainingSlots)
                                          .map((file) => file.path)
                                          .toList();
                                      selectedImages.addAll(filesToAdd);
                                    });
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blue[50],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        color: Colors.blue[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Dodaj nove fotografije',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Maksimalno 10 fotografija',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (currentImageUrls.isEmpty &&
                                selectedImages.isEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Objava mora imati najmanje jednu fotografiju',
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
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              'Otkaži',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ||
                                    contentController.text.length > 1000 ||
                                    (currentImageUrls.isEmpty &&
                                        selectedImages.isEmpty)
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await _updatePostWithPhotos(
                                      post,
                                      contentController.text.trim(),
                                      currentImageUrls,
                                      selectedImages,
                                      setModalState,
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Ažuriraj',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
      ),
    );
  }

  Future<void> _updatePostWithPhotos(
    Post post,
    String content,
    List<String> currentImageUrls,
    List<String> selectedImages,
    StateSetter setModalState,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = PostProvider(authProvider);

      List<String> newImageUrls = [];
      for (String imagePath in selectedImages) {
        final imageFile = File(imagePath);
        final imageUrl = await postProvider.uploadImage(imageFile);
        newImageUrls.add(imageUrl);
      }

      List<String> allImageUrls = [...currentImageUrls, ...newImageUrls];

      await postProvider.updatePost(post.id, content, allImageUrls);

      if (mounted) {
        await _loadPosts();
        setModalState(() {
          // Force rebuild to get fresh data from _posts list
        });

        SnackBarUtils.showSuccessSnackBar(
          'Objava je uspješno ažurirana',
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

class CreatePostForm extends StatefulWidget {
  final Activity activity;
  final VoidCallback onPostCreated;

  const CreatePostForm({
    super.key,
    required this.activity,
    required this.onPostCreated,
  });

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final TextEditingController _contentController = TextEditingController();
  List<String> _selectedImages = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objavi fotografije',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Podijelite fotografije sa aktivnosti',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opis objave',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Dodaj opis objave...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue[400]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 5,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Opis je opcionalan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            '${_contentController.text.length}/1000',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _contentController.text.length > 1000
                                  ? Colors.red[600]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Fotografije',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          if (_selectedImages.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedImages.length}/10',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_selectedImages.isNotEmpty)
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_selectedImages[index]),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.red[600],
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
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
                            },
                          ),
                        ),

                      const SizedBox(height: 20),

                      if (_selectedImages.length < 10)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(
                              _selectedImages.isEmpty
                                  ? 'Dodaj fotografije'
                                  : 'Dodaj još fotografija',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                      if (_selectedImages.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nema odabranih fotografija',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dodajte do 10 fotografija',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImages.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Odaberite najmanje jednu fotografiju',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Otkaži',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            _isUploading ||
                                _selectedImages.isEmpty ||
                                _contentController.text.length > 1000
                            ? null
                            : _createPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Objavljivanje...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Objavi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        final remainingSlots = 10 - _selectedImages.length;
        final filesToAdd = pickedFiles
            .take(remainingSlots)
            .map((file) => file.path)
            .toList();
        _selectedImages.addAll(filesToAdd);
      });
    }
  }

  Future<void> _createPost() async {
    if (_selectedImages.isEmpty) {
      SnackBarUtils.showWarningSnackBar(
        'Molimo odaberite najmanje jednu fotografiju',
        context: context,
      );
      return;
    }

    if (_contentController.text.length > 1000) {
      SnackBarUtils.showErrorSnackBar(
        'Opis može imati maksimalno 1000 karaktera',
        context: context,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = PostProvider(authProvider);

      List<String> uploadedImageUrls = [];

      for (final imagePath in _selectedImages) {
        final imageFile = File(imagePath);
        final imageUrl = await postProvider.uploadImage(imageFile);
        uploadedImageUrls.add(imageUrl);
      }

      await postProvider.createPost(
        _contentController.text.trim(),
        widget.activity.id,
        uploadedImageUrls,
      );

      widget.onPostCreated();

      SnackBarUtils.showSuccessSnackBar(
        'Objava je uspješno kreirana!',
        context: context,
      );
    } catch (e) {
      SnackBarUtils.showErrorSnackBar(e, context: context);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}

class _ImageCarouselWidget extends StatefulWidget {
  final List<PostImage> images;

  const _ImageCarouselWidget({required this.images});

  @override
  State<_ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<_ImageCarouselWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    UrlUtils.buildImageUrl(widget.images[index].imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          if (widget.images.length > 1)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

          if (widget.images.length > 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex < widget.images.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

          if (widget.images.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
