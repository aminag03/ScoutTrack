import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/badge_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_details_screen.dart';
import 'package:scouttrack_desktop/models/member_badge.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/providers/member_badge_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/providers/badge_provider.dart';
import 'package:scouttrack_desktop/providers/member_badge_progress_provider.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/models/member_badge_progress.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';

class MemberBadgeListScreen extends StatefulWidget {
  final int? badgeId;
  final int? initialStatus;
  final int? initialTroopId;

  const MemberBadgeListScreen({
    super.key,
    this.badgeId,
    this.initialStatus,
    this.initialTroopId,
  });

  @override
  State<MemberBadgeListScreen> createState() => _MemberBadgeListScreenState();
}

class _MemberBadgeListScreenState extends State<MemberBadgeListScreen> {
  SearchResult<MemberBadge>? _memberBadges;
  bool _loading = false;
  String? _error;
  String? _role;
  int? _loggedInUserId;
  final ScrollController _scrollController = ScrollController();

  int? _selectedStatus;
  int? _selectedTroopId;
  int? _selectedBadgeId;
  String? _selectedSort;
  List<Troop> _troops = [];
  List<Badge> _badges = [];
  Map<int, String> _memberTroopNames = {}; // Map memberId to troop name

  late MemberBadgeProvider _memberBadgeProvider;
  late TroopProvider _troopProvider;
  late BadgeProvider _badgeProvider;

  int currentPage = 1;
  int pageSize = 20;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        _memberBadgeProvider = MemberBadgeProvider(authProvider);
        _troopProvider = TroopProvider(authProvider);
        _badgeProvider = BadgeProvider(authProvider);

        if (_role == null) {
          _loadInitialData();
        }
      }
    } catch (e) {
      print('AuthProvider not available: $e');
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    // Set initial values from widget parameters
    if (widget.initialStatus != null) {
      _selectedStatus = widget.initialStatus;
    }
    if (widget.initialTroopId != null) {
      _selectedTroopId = widget.initialTroopId;
    }
    if (widget.badgeId != null) {
      _selectedBadgeId = widget.badgeId;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        print('User not authenticated, skipping data load');
        return;
      }

      final role = await authProvider.getUserRole();
      final userId = await authProvider.getUserIdFromToken();

      if (!mounted) return;

      setState(() {
        _role = role;
        _loggedInUserId = userId;
      });

      // For troop users, automatically set their troop as the filter
      if (role == 'Troop' && _selectedTroopId == null) {
        _selectedTroopId = userId;
      }

      // Load troops for filtering
      var filter = {"RetrieveAll": true};
      final troopResult = await _troopProvider.get(filter: filter);

      if (!mounted) return;

      setState(() {
        _troops = troopResult.items ?? [];
      });

      // For troop users, ensure their troop exists in the loaded troops
      if (_role == 'Troop' && _selectedTroopId != null) {
        if (!_troops.any((troop) => troop.id == _selectedTroopId)) {
          // If the selected troop doesn't exist in the loaded troops, reset it
          _selectedTroopId = null;
        }
      }

      // Load badges for filtering
      final badgeResult = await _badgeProvider.get(filter: filter);

      if (!mounted) return;

      setState(() {
        _badges = badgeResult.items ?? [];

        // Ensure the selected badge ID exists in the loaded badges
        if (_selectedBadgeId != null &&
            !_badges.any((badge) => badge.id == _selectedBadgeId)) {
          _selectedBadgeId = null;
        }
      });

      // Load member-troop relationships for admin users
      if (_role == 'Admin') {
        await _loadMemberTroopNames();
      }

      await _fetchMemberBadges();
    } catch (e) {
      print('Error in _loadInitialData: $e');
    }
  }

  Future<void> _fetchMemberBadges({int? page}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var filter = {
        if (_selectedBadgeId != null) "BadgeId": _selectedBadgeId,
        if (_selectedStatus != null) "Status": _selectedStatus,
        if (_selectedTroopId != null) "TroopId": _selectedTroopId,
        if (_selectedSort != null) "OrderBy": _selectedSort,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };

      final result = await _memberBadgeProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _memberBadges = result;
          _loading = false;
          currentPage = page ?? currentPage;
          totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _memberBadges = null;
          _loading = false;
        });
      }
    }
  }

  void _onViewMemberBadge(MemberBadge memberBadge) {
    // Show member badge progress dialog (same as in badge_details_screen.dart)
    _showMemberBadgeProgressDialog(memberBadge);
  }

  void _showMemberBadgeProgressDialog(MemberBadge memberBadge) {
    showDialog(
      context: context,
      builder: (context) => MemberBadgeProgressDialog(
        memberBadge: memberBadge,
        badge: _createDummyBadge(memberBadge),
        role: _role ?? '',
        loggedInUserId: _loggedInUserId ?? 0,
        onProgressUpdated: _fetchMemberBadges,
      ),
    );
  }

  void _onViewMember(MemberBadge memberBadge) {
    // Navigate to member details screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberDetailsScreen(
          member: _createDummyMember(memberBadge),
          role: _role ?? '',
          loggedInUserId: _loggedInUserId ?? 0,
          selectedMenu: 'Članovi',
        ),
      ),
    );
  }

  // Temporary helper methods - these would need proper implementation
  Badge _createDummyBadge(MemberBadge memberBadge) {
    return Badge(
      id: memberBadge.badgeId,
      name: memberBadge.badgeName,
      description: '',
      imageUrl: memberBadge.badgeImageUrl,
      createdAt: memberBadge.createdAt,
    );
  }

  Member _createDummyMember(MemberBadge memberBadge) {
    return Member(
      id: memberBadge.memberId,
      firstName: memberBadge.memberFirstName,
      lastName: memberBadge.memberLastName,
      username: '',
      email: '',
      profilePictureUrl: memberBadge.memberProfilePictureUrl,
      birthDate:
          DateTime.now(), // Required field, using current date as fallback
      gender: 0,
      cityId: 0,
      troopId: 0,
      contactPhone: '',
      createdAt: memberBadge.createdAt,
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'U toku';
      case 1:
        return 'Završeno';
      default:
        return 'Nepoznato';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadMemberTroopNames() async {
    try {
      // Get all members to build troop relationships
      final memberProvider = MemberProvider(_memberBadgeProvider.authProvider);
      final filter = {'RetrieveAll': true};
      final memberResult = await memberProvider.get(filter: filter);

      if (!mounted) return;

      final memberTroopNames = <int, String>{};

      for (final member in memberResult.items ?? []) {
        final troop = _troops.firstWhere(
          (troop) => troop.id == member.troopId,
          orElse: () => Troop(
            id: 0,
            name: 'Nepoznato',
            cityId: 0,
            createdAt: DateTime.now(),
            foundingDate: DateTime.now(),
          ),
        );
        memberTroopNames[member.id] = troop.name;
      }

      setState(() {
        _memberTroopNames = memberTroopNames;
      });
    } catch (e) {
      print('Error loading member troop names: $e');
    }
  }

  String _getTroopName(int memberId) {
    return _memberTroopNames[memberId] ?? 'Nepoznato';
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? '',
      selectedMenu: 'Vještarstva',
      title: 'Lista vještarstava članova',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                          currentPage = 1;
                        });
                        _fetchMemberBadges();
                      },
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text("Svi statusi"),
                        ),
                        DropdownMenuItem(value: 0, child: Text("U toku")),
                        DropdownMenuItem(value: 1, child: Text("Završeno")),
                      ],
                    ),
                  ),
                ),
                // Only show troop filter for Admin users
                if (_role != 'Troop')
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: DropdownButtonFormField<int?>(
                        value:
                            _selectedTroopId != null &&
                                _troops.any(
                                  (troop) => troop.id == _selectedTroopId,
                                )
                            ? _selectedTroopId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Odred',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedTroopId = value;
                            currentPage = 1;
                          });
                          _fetchMemberBadges();
                        },
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Svi odredi"),
                          ),
                          ..._troops.map(
                            (troop) => DropdownMenuItem(
                              value: troop.id,
                              child: Text(troop.name),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value:
                          _selectedBadgeId != null &&
                              _badges.any(
                                (badge) => badge.id == _selectedBadgeId,
                              )
                          ? _selectedBadgeId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Vještarstvo',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedBadgeId = value;
                          currentPage = 1;
                        });
                        _fetchMemberBadges();
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Sva vještarstva"),
                        ),
                        ..._badges.map(
                          (badge) => DropdownMenuItem(
                            value: badge.id,
                            child: Text(badge.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String?>(
                      value: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Sortiraj',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                          currentPage = 1;
                        });
                        _fetchMemberBadges();
                      },
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Bez sortiranja'),
                        ),
                        DropdownMenuItem(
                          value: 'memberFirstName',
                          child: Text('Ime člana (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-memberFirstName',
                          child: Text('Ime člana (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'badgeName',
                          child: Text('Naziv vještarstva (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-badgeName',
                          child: Text('Naziv vještarstva (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'createdAt',
                          child: Text('Datum početka (najstariji)'),
                        ),
                        DropdownMenuItem(
                          value: '-createdAt',
                          child: Text('Datum početka (najnoviji)'),
                        ),
                        DropdownMenuItem(
                          value: 'completedAt',
                          child: Text('Datum završetka (najstariji)'),
                        ),
                        DropdownMenuItem(
                          value: '-completedAt',
                          child: Text('Datum završetka (najnoviji)'),
                        ),
                        DropdownMenuItem(
                          value: 'status',
                          child: Text('Status (U toku → Završeno)'),
                        ),
                        DropdownMenuItem(
                          value: '-status',
                          child: Text('Status (Završeno → U toku)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Results count
            if (_memberBadges != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        Icon(
                          Icons.info_outline,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Prikazano ${_memberBadges!.items?.length ?? 0} od ukupno ${_memberBadges!.totalCount ?? 0} vještarstava članova',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (_role == 'Troop') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            color: Colors.blue.shade700,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Prikazuju se samo vještarstva vaših članova',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildResultView()),
                  const SizedBox(height: 4),
                  if (_memberBadges != null)
                    PaginationControls(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      totalCount: _memberBadges?.totalCount ?? 0,
                      onPageChanged: (page) => _fetchMemberBadges(page: page),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Greška: $_error',
              style: TextStyle(fontSize: 16, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMemberBadges,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_memberBadges?.items == null || _memberBadges!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nema pronađenih vještarstava.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _memberBadges!.items!.length,
      itemBuilder: (context, index) {
        final memberBadge = _memberBadges!.items![index];
        return GestureDetector(
          onTap: () => _onViewMemberBadge(memberBadge),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage:
                                  memberBadge.memberProfilePictureUrl.isNotEmpty
                                  ? NetworkImage(
                                      memberBadge.memberProfilePictureUrl,
                                    )
                                  : null,
                              child: memberBadge.memberProfilePictureUrl.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey.shade600,
                                      size: 22,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  memberBadge.memberFullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(memberBadge.status),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getStatusColor(
                                          memberBadge.status,
                                        ).withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _getStatusText(memberBadge.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              memberBadge.badgeName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.green.shade700,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_role == 'Admin') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: Colors.blue.shade600,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getTroopName(memberBadge.memberId),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Započeto: ${formatDateTime(memberBadge.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (memberBadge.completedAt != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Završeno: ${formatDateTime(memberBadge.completedAt!)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MemberBadgeProgressDialog extends StatefulWidget {
  final MemberBadge memberBadge;
  final Badge badge;
  final String role;
  final int loggedInUserId;
  final VoidCallback onProgressUpdated;

  const MemberBadgeProgressDialog({
    super.key,
    required this.memberBadge,
    required this.badge,
    required this.role,
    required this.loggedInUserId,
    required this.onProgressUpdated,
  });

  @override
  State<MemberBadgeProgressDialog> createState() =>
      _MemberBadgeProgressDialogState();
}

class _MemberBadgeProgressDialogState extends State<MemberBadgeProgressDialog> {
  List<MemberBadgeProgress> _progressList = [];
  bool _loading = false;
  bool _updating = false;

  late MemberBadgeProgressProvider _progressProvider;
  late MemberBadgeProvider _memberBadgeProvider;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _progressProvider = MemberBadgeProgressProvider(authProvider);
    _memberBadgeProvider = MemberBadgeProvider(authProvider);
    _loadProgress();
  }

  void _navigateToMemberProfile(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Učitavanje podataka o članu...'),
            ],
          ),
        ),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = MemberProvider(authProvider);
      final member = await memberProvider.getById(widget.memberBadge.memberId);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted && member != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemberDetailsScreen(
              member: member,
              role: widget.role,
              loggedInUserId: widget.loggedInUserId,
              selectedMenu: 'Članovi',
            ),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Greška: Nije moguće učitati podatke o članu "${widget.memberBadge.memberFullName}"',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _loadProgress() async {
    setState(() {
      _loading = true;
    });

    try {
      final progress = await _progressProvider.getByMemberBadgeId(
        widget.memberBadge.id,
      );
      setState(() {
        _progressList = progress;
        _loading = false;
      });
    } catch (e) {
      showErrorSnackbar(context, e);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateProgressCompletion(
    MemberBadgeProgress progress,
    bool isCompleted,
  ) async {
    setState(() {
      _updating = true;
    });

    try {
      if (progress.id == null) return;
      await _progressProvider.updateCompletion(progress.id!, isCompleted);

      setState(() {
        final index = _progressList.indexWhere((p) => p.id == progress.id);
        if (index != -1) {
          _progressList[index] = MemberBadgeProgress(
            id: progress.id!,
            memberBadgeId: progress.memberBadgeId,
            requirementId: progress.requirementId,
            requirementDescription: progress.requirementDescription,
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
            createdAt: progress.createdAt,
          );
        }
        _updating = false;
      });
    } catch (e) {
      showErrorSnackbar(context, e);
      setState(() {
        _updating = false;
      });
    }
  }

  Future<void> _completeBadge() async {
    try {
      await _memberBadgeProvider.completeMemberBadge(widget.memberBadge.id);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onProgressUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vještarstvo je uspješno dodijeljeno')),
        );
      }
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _revertBadgeToInProgress() async {
    try {
      final request = {
        'memberId': widget.memberBadge.memberId,
        'badgeId': widget.memberBadge.badgeId,
        'status': 0, // InProgress
        'completedAt': null as DateTime?,
      };

      await _memberBadgeProvider.update(widget.memberBadge.id, request);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onProgressUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vještarstvo je vraćeno u status "U toku"'),
          ),
        );
      }
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _deleteMemberBadge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati člana "${widget.memberBadge.memberFullName}" iz vještarstva "${widget.badge.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _memberBadgeProvider.delete(widget.memberBadge.id);
        if (mounted) {
          Navigator.of(context).pop();
          widget.onProgressUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Član je uspješno obrisan iz vještarstva'),
            ),
          );
        }
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  bool get _allRequirementsCompleted {
    return _progressList.every((progress) => progress.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage:
                      widget.memberBadge.memberProfilePictureUrl.isNotEmpty
                      ? NetworkImage(widget.memberBadge.memberProfilePictureUrl)
                      : null,
                  child: widget.memberBadge.memberProfilePictureUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToMemberProfile(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.memberBadge.memberFullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                                decorationThickness: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.blue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Uslovi za vještarstvo:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_progressList.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  border: Border.all(color: Colors.yellow.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.yellow.shade700,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nema zapisanog napretka za ovo vještarstvo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _progressList.length,
                  itemBuilder: (context, index) {
                    final progress = _progressList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          progress.requirementDescription,
                          style: TextStyle(
                            decoration: progress.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: progress.isCompleted
                                ? Colors.grey.shade600
                                : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: progress.isCompleted,
                          onChanged: _updating
                              ? null
                              : (value) {
                                  if (value != null) {
                                    _updateProgressCompletion(progress, value);
                                  }
                                },
                        ),
                        trailing:
                            progress.isCompleted && progress.completedAt != null
                            ? Text(
                                'Završeno: ${formatDateTime(progress.completedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            if (_allRequirementsCompleted &&
                widget.role != 'Member' &&
                widget.memberBadge.status != 1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updating ? null : _completeBadge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _updating
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
                          'Dodijeli vještarstvo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            if (widget.memberBadge.status == 1 && widget.role != 'Member')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updating ? null : _revertBadgeToInProgress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _updating
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
                          'Ukloni vještarstvo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            if (widget.memberBadge.status == 0 && widget.role != 'Member')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updating ? null : _deleteMemberBadge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _updating
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
                          'Obriši vještarstvo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zatvori'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
