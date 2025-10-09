import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/badge_provider.dart';
import '../providers/member_badge_provider.dart';
import '../models/badge.dart';
import '../models/member_badge.dart';
import '../models/badge_requirement.dart';
import '../models/member_badge_progress.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import '../providers/member_provider.dart';

class DetailedBadgeListScreen extends StatefulWidget {
  final String sectionTitle;
  final List<ScoutBadge> badges;
  final List<MemberBadge> memberBadges;
  final BadgeSectionType sectionType;
  final bool isViewingOtherMember;

  const DetailedBadgeListScreen({
    super.key,
    required this.sectionTitle,
    required this.badges,
    required this.memberBadges,
    required this.sectionType,
    this.isViewingOtherMember = false,
  });

  @override
  State<DetailedBadgeListScreen> createState() =>
      _DetailedBadgeListScreenState();
}

class _DetailedBadgeListScreenState extends State<DetailedBadgeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ScoutBadge> _filteredBadges = [];

  @override
  void initState() {
    super.initState();
    _filteredBadges = widget.badges;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBadges(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBadges = widget.badges;
      } else {
        _filteredBadges = widget.badges
            .where(
              (badge) =>
                  badge.name.toLowerCase().contains(query.toLowerCase()) ||
                  badge.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _showBadgeDetails(ScoutBadge badge) {
    try {
      final memberBadge = widget.memberBadges.firstWhere(
        (mb) => mb.badgeId == badge.id,
      );
      showDialog(
        context: context,
        builder: (context) =>
            _BadgeDetailsDialog(badge: badge, memberBadge: memberBadge),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) =>
            _BadgeDetailsDialog(badge: badge, memberBadge: null),
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
                Navigator.of(context).pop(true);
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterBadges,
        decoration: InputDecoration(
          hintText: 'Pretraži vještarstva...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterBadges('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(ScoutBadge badge) {
    switch (widget.sectionType) {
      case BadgeSectionType.completed:
        return _buildCompletedBadgeCard(badge);
      case BadgeSectionType.inProgress:
        return _buildInProgressBadgeCard(badge);
      case BadgeSectionType.waiting:
        return _buildWaitingBadgeCard(badge);
    }
  }

  Widget _buildCompletedBadgeCard(ScoutBadge badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF558B6E),
                    ),
                  ),
                )
              : const Icon(Icons.star_rounded, color: Color(0xFF558B6E)),
        ),
        title: Text(
          badge.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          badge.description,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        onTap: () => _showBadgeDetails(badge),
      ),
    );
  }

  Widget _buildInProgressBadgeCard(ScoutBadge badge) {
    final memberBadge = widget.memberBadges.firstWhere(
      (mb) => mb.badgeId == badge.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF558B6E),
                    ),
                  ),
                )
              : const Icon(Icons.star_rounded, color: Color(0xFF558B6E)),
        ),
        title: Text(
          badge.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FutureBuilder<double>(
              future: _getBadgeProgress(badge.id, memberBadge.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Učitavam...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }
                final progress = snapshot.data ?? 0.0;
                return Text(
                  '${progress.toInt()}% završeno',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF558B6E),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
        trailing: !widget.isViewingOtherMember
            ? PopupMenuButton<String>(
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
                child: const Icon(Icons.more_vert, color: Colors.grey),
              )
            : null,
        onTap: () => _showBadgeDetails(badge),
      ),
    );
  }

  Widget _buildWaitingBadgeCard(ScoutBadge badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
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
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.star_rounded, color: Colors.grey[500]),
                  ),
                )
              : Icon(Icons.star_rounded, color: Colors.grey[500]),
        ),
        title: Text(
          badge.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          badge.description,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          onPressed: () => _startBadgeChallenge(badge),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF558B6E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Započni'),
        ),
        onTap: () => _showBadgeDetails(badge),
      ),
    );
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
      final memberBadge = widget.memberBadges.firstWhere(
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
                Navigator.of(context).pop(true);
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
      headerTitle: widget.sectionTitle,
      showBackButton: true,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredBadges.isEmpty
                ? const Center(
                    child: Text(
                      'Nema vještarstva koja odgovaraju Vašoj pretrazi.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredBadges.length,
                    itemBuilder: (context, index) {
                      final badge = _filteredBadges[index];
                      return _buildBadgeCard(badge);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

enum BadgeSectionType { completed, inProgress, waiting }

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
            color: progress.isCompleted
                ? const Color(0xFF558B6E)
                : Colors.grey[400],
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
                        ? const Color(0xFF558B6E)
                        : Colors.black87,
                    fontWeight: progress.isCompleted
                        ? FontWeight.w500
                        : FontWeight.normal,
                    decoration: progress.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (progress.isCompleted && progress.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Završeno: ${_formatDate(progress.completedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF558B6E),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.badge.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            Expanded(
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
}
