import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/badge_provider.dart';
import '../providers/member_badge_provider.dart';
import '../providers/member_provider.dart';
import '../models/badge.dart';
import '../models/member_badge.dart';
import '../models/badge_requirement.dart';
import '../models/member_badge_progress.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'detailed_badge_list_screen.dart';

class BadgeListScreen extends StatefulWidget {
  final int? memberId;

  const BadgeListScreen({super.key, this.memberId});

  @override
  State<BadgeListScreen> createState() => _BadgeListScreenState();
}

class _BadgeListScreenState extends State<BadgeListScreen> {
  List<ScoutBadge> _allBadges = [];
  List<MemberBadge> _memberBadges = [];
  bool _isLoading = true;
  String? _error;

  static const int _completedLimit = 4;
  static const int _inProgressLimit = 3;
  static const int _waitingLimit = 6;

  bool get _isViewingOtherMember => widget.memberId != null;

  List<ScoutBadge> get _completedBadges {
    final completedMemberBadges = _memberBadges
        .where((mb) => mb.status == MemberBadgeStatus.completed)
        .toList();
    return _allBadges
        .where(
          (badge) => completedMemberBadges.any((mb) => mb.badgeId == badge.id),
        )
        .toList();
  }

  List<ScoutBadge> get _inProgressBadges {
    final inProgressMemberBadges = _memberBadges
        .where((mb) => mb.status == MemberBadgeStatus.inProgress)
        .toList();
    return _allBadges
        .where(
          (badge) => inProgressMemberBadges.any((mb) => mb.badgeId == badge.id),
        )
        .toList();
  }

  List<ScoutBadge> get _waitingToStartBadges {
    final completedOrInProgressBadgeIds = _memberBadges
        .map((mb) => mb.badgeId)
        .toSet();
    return _allBadges
        .where((badge) => !completedOrInProgressBadgeIds.contains(badge.id))
        .toList();
  }

  Future<void> _navigateToDetailedScreen(
    String sectionTitle,
    List<ScoutBadge> badges,
    BadgeSectionType sectionType,
  ) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedBadgeListScreen(
          sectionTitle: sectionTitle,
          badges: badges,
          memberBadges: _memberBadges,
          sectionType: sectionType,
          isViewingOtherMember: _isViewingOtherMember,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      int memberId;
      if (_isViewingOtherMember) {
        memberId = widget.memberId!;
      } else {
        final userInfo = await authProvider.getCurrentUserInfo();
        if (userInfo != null && userInfo['id'] != null) {
          memberId = userInfo['id'] as int;
        } else {
          if (mounted) {
            setState(() {
              _error = 'Nije moguće dohvatiti podatke o članu';
              _isLoading = false;
            });
          }
          return;
        }
      }

      final futures = await Future.wait([
        badgeProvider.get(filter: {"RetrieveAll": true}),
        memberBadgeProvider.getMemberBadges(memberId),
      ]);

      final badgeResult = futures[0] as dynamic;
      final memberBadges = futures[1] as List<MemberBadge>;

      if (mounted) {
        setState(() {
          _allBadges = badgeResult.items ?? [];
          _memberBadges = memberBadges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Greška pri učitavanju podataka: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _showBadgeDetails(ScoutBadge badge) {
    try {
      final memberBadge = _memberBadges.firstWhere(
        (mb) => mb.badgeId == badge.id,
      );
      showDialog(
        context: context,
        builder: (context) => _BadgeDetailsDialog(
          badge: badge,
          memberBadge: memberBadge,
          isViewingOtherMember: _isViewingOtherMember,
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => _BadgeDetailsDialog(
          badge: badge,
          memberBadge: null,
          isViewingOtherMember: _isViewingOtherMember,
        ),
      );
    }
  }

  Future<void> _startBadgeChallenge(ScoutBadge badge) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final requirements = await badgeProvider.getBadgeRequirements(badge.id);

      final currentUser = await authProvider.fetchCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser['id'];
      final username = currentUser['username'] ?? '';

      if (userId == null) {
        throw Exception('User ID not found');
      }

      int? troopId;
      try {
        final memberProvider = MemberProvider(authProvider);
        final memberDetails = await memberProvider.getById(userId);
        troopId = memberDetails.troopId;
      } catch (e) {
        print('DEBUG: Failed to get member details: $e');
      }

      bool canSendNotification = troopId != null;
      if (!canSendNotification) {
        print('DEBUG: Cannot send notification - troopId is null');
      }

      await memberBadgeProvider.startBadgeChallenge(
        userId,
        badge.id,
        requirements,
      );

      if (canSendNotification) {
        try {
          await memberBadgeProvider.notifyTroopAboutBadgeStart(
            userId,
            username.isNotEmpty ? username : 'Član',
            badge.name,
            troopId,
          );
        } catch (notificationError) {
          print('Failed to send notification: $notificationError');
        }
      } else {
        print('DEBUG: Skipping notification - insufficient user data');
      }

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Izazov započet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF558B6E),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF558B6E),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Uspješno ste započeli rad na vještarstvu "${badge.name}".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                canSendNotification
                    ? 'Vaš odred je obaviješten i pratit će Vaš napredak. Oni će dodjeljivati uslove i vještarstvo prema potrebi.'
                    : 'Možete početi rad na uslovima. Kontaktirajte Vaš odred za dodjeljivanje napretka.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadData();
              },
              child: const Text(
                'U redu',
                style: TextStyle(
                  color: Color(0xFF558B6E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      SnackBarUtils.showErrorSnackBar(
        'Greška pri pokretanju izazova: ${e.toString()}',
        context: context,
      );
    }
  }

  Future<double> _getBadgeProgress(int badgeId, int memberBadgeId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      final futures = await Future.wait([
        badgeProvider.getBadgeRequirements(badgeId),
        memberBadgeProvider.getMemberBadgeProgress(memberBadgeId),
      ]);

      final requirements = futures[0] as List<BadgeRequirement>;
      final progress = futures[1] as List<MemberBadgeProgress>;

      if (requirements.isEmpty) return 0.0;

      final completedCount = progress.where((p) => p.isCompleted).length;
      return (completedCount / requirements.length) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _cancelBadgeChallenge(ScoutBadge badge) async {
    try {
      final memberBadge = _memberBadges.firstWhere(
        (mb) => mb.badgeId == badge.id,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Otkaži izazov',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Jeste li sigurni da želite otkazati izazov "${badge.name}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sav napredak na vještarstvu će biti obrisan i nećete ga moći vratiti.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Odustani',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Otkaži izazov',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberBadgeProvider = MemberBadgeProvider(authProvider);

      await memberBadgeProvider.deleteMemberBadge(memberBadge.id);

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Izazov otkazan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                'Uspješno ste otkazali izazov "${badge.name}".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Možete ga ponovno započeti kada budete spremni.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadData();
              },
              child: const Text(
                'U redu',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      SnackBarUtils.showErrorSnackBar(
        'Greška pri otkazivanju izazova: ${e.toString()}',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: _isViewingOtherMember ? 'Vještarstva' : 'Moja vještarstva',
      selectedIndex: -1,
      body: Container(color: const Color(0xFFF5F5DC), child: _buildBody()),
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
              onPressed: _loadData,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompletedSection(),
          const SizedBox(height: 24),
          _buildInProgressSection(),
          if (!_isViewingOtherMember) ...[
            const SizedBox(height: 24),
            _buildWaitingToStartSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedSection() {
    if (_completedBadges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Završeno',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _completedBadges.length > _completedLimit
              ? _completedLimit
              : _completedBadges.length,
          itemBuilder: (context, index) {
            final badge = _completedBadges[index];
            return _buildBadgeCard(badge, true);
          },
        ),
        if (_completedBadges.length > _completedLimit)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _navigateToDetailedScreen(
                  'Završena vještarstva',
                  _completedBadges,
                  BadgeSectionType.completed,
                ),
                child: const Text(
                  'Prikaži više',
                  style: TextStyle(
                    color: Color(0xFF558B6E),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInProgressSection() {
    if (_inProgressBadges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'U toku',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...(_inProgressBadges
            .take(_inProgressLimit)
            .map((badge) => _buildInProgressBadgeCard(badge))),
        if (_inProgressBadges.length > _inProgressLimit) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToDetailedScreen(
                'Vještarstva u toku',
                _inProgressBadges,
                BadgeSectionType.inProgress,
              ),
              child: const Text(
                'Prikaži više',
                style: TextStyle(
                  color: Color(0xFF558B6E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        if (!_isViewingOtherMember) ...[
          const SizedBox(height: 16),
          _buildTroopContactInfo(),
        ],
      ],
    );
  }

  Widget _buildWaitingToStartSection() {
    if (_waitingToStartBadges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Čekaju na početak',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemCount: _waitingToStartBadges.length > _waitingLimit
                ? _waitingLimit
                : _waitingToStartBadges.length,
            itemBuilder: (context, index) {
              final badge = _waitingToStartBadges[index];
              return Padding(
                padding: EdgeInsets.only(
                  right:
                      index <
                          (_waitingToStartBadges.length > _waitingLimit
                                  ? _waitingLimit
                                  : _waitingToStartBadges.length) -
                              1
                      ? 16
                      : 0,
                ),
                child: SizedBox(
                  width: 160,
                  child: _buildWaitingBadgeCard(badge),
                ),
              );
            },
          ),
        ),
        if (_waitingToStartBadges.length > _waitingLimit) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToDetailedScreen(
                'Čekaju na početak',
                _waitingToStartBadges,
                BadgeSectionType.waiting,
              ),
              child: const Text(
                'Prikaži više',
                style: TextStyle(
                  color: Color(0xFF558B6E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgeCard(ScoutBadge badge, bool isCompleted) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF558B6E).withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF558B6E).withOpacity(0.1)
                      : Colors.grey[50],
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF558B6E)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: badge.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          UrlUtils.buildImageUrl(badge.imageUrl),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: isCompleted
                                    ? const Color(0xFF558B6E)
                                    : Colors.grey[400],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.star_rounded,
                            color: isCompleted
                                ? const Color(0xFF558B6E)
                                : Colors.grey[500],
                            size: 32,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.star_rounded,
                        color: isCompleted
                            ? const Color(0xFF558B6E)
                            : Colors.grey[500],
                        size: 32,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isCompleted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF558B6E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Završeno',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroopContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF558B6E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF558B6E).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF558B6E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF558B6E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontaktirajte Vaš odred za provjeru napretka i dodjelu vještarstva.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressBadgeCard(ScoutBadge badge) {
    final memberBadge = _memberBadges.firstWhere(
      (mb) => mb.badgeId == badge.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF558B6E).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showBadgeDetails(badge),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                child: badge.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          UrlUtils.buildImageUrl(badge.imageUrl),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF558B6E),
                              ),
                            );
                          },
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
                      badge.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF558B6E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'U toku',
                        style: TextStyle(
                          color: Color(0xFF558B6E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: _getBadgeProgress(badge.id, memberBadge.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF558B6E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Učitavam...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }

                        final progress = snapshot.data ?? 0.0;
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF558B6E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progress.toInt()}% završeno',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF558B6E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!_isViewingOtherMember)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _cancelBadgeChallenge(badge);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Otkaži izazov',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingBadgeCard(ScoutBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: badge.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          UrlUtils.buildImageUrl(badge.imageUrl),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.star_rounded,
                            color: Colors.grey[500],
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.star_rounded,
                        color: Colors.grey[500],
                        size: 28,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startBadgeChallenge(badge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF558B6E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Započni izazov'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeDetailsDialog extends StatefulWidget {
  final ScoutBadge badge;
  final MemberBadge? memberBadge;
  final bool isViewingOtherMember;

  const _BadgeDetailsDialog({
    required this.badge,
    this.memberBadge,
    this.isViewingOtherMember = false,
  });

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
        SnackBarUtils.showErrorSnackBar(
          'Greška pri učitavanju detalja: ${e.toString()}',
          context: context,
        );
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
                              UrlUtils.buildImageUrl(widget.badge.imageUrl),
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
            if (widget.memberBadge != null && !widget.isViewingOtherMember) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF558B6E).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF558B6E).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF558B6E),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Za dodjeljivanje napretka i vještarstva kontaktirajte Vaš odred.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF558B6E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
