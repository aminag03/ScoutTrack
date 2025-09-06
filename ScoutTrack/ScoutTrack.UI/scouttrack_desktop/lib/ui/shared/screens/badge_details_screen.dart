import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/badge_requirement.dart';
import 'package:scouttrack_desktop/models/member_badge.dart';
import 'package:scouttrack_desktop/models/member_badge_progress.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/badge_requirement_provider.dart';
import 'package:scouttrack_desktop/providers/member_badge_provider.dart';
import 'package:scouttrack_desktop/providers/member_badge_progress_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_badge_list_screen.dart';

class BadgeDetailsScreen extends StatefulWidget {
  final Badge badge;
  final String role;
  final int loggedInUserId;

  const BadgeDetailsScreen({
    super.key,
    required this.badge,
    required this.role,
    required this.loggedInUserId,
  });

  @override
  State<BadgeDetailsScreen> createState() => _BadgeDetailsScreenState();
}

class _BadgeDetailsScreenState extends State<BadgeDetailsScreen> {
  List<BadgeRequirement> _requirements = [];
  List<MemberBadge> _completedMembers = [];
  List<MemberBadge> _inProgressMembers = [];
  bool _loadingRequirements = false;
  bool _loadingMembers = false;
  Map<int, String> _memberTroopNames = {};
  final ScrollController _scrollController = ScrollController();
  final ScrollController _completedMembersScrollController = ScrollController();
  final ScrollController _inProgressMembersScrollController =
      ScrollController();

  late BadgeRequirementProvider _badgeRequirementProvider;
  late MemberBadgeProvider _memberBadgeProvider;
  late TroopProvider _troopProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _badgeRequirementProvider = BadgeRequirementProvider(authProvider);
    _memberBadgeProvider = MemberBadgeProvider(authProvider);
    _troopProvider = TroopProvider(authProvider);
    _loadRequirements();
    _loadMembers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _completedMembersScrollController.dispose();
    _inProgressMembersScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRequirements() async {
    setState(() {
      _loadingRequirements = true;
    });

    try {
      final filter = {
        'BadgeId': widget.badge.id,
        'Page': 0,
        'PageSize': 20,
        'IncludeTotalCount': false,
      };

      final result = await _badgeRequirementProvider.get(filter: filter);
      setState(() {
        _requirements = result.items?.cast<BadgeRequirement>() ?? [];
        _loadingRequirements = false;
      });
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loadingMembers = true;
    });

    try {
      if (widget.role == 'Troop') {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final troopId = await authProvider.getUserIdFromToken() ?? 0;

        final completedMembers = await _memberBadgeProvider
            .getMembersByBadgeStatusAndTroop(widget.badge.id, 1, troopId);

        final inProgressMembers = await _memberBadgeProvider
            .getMembersByBadgeStatusAndTroop(widget.badge.id, 0, troopId);

        setState(() {
          _completedMembers = completedMembers;
          _inProgressMembers = inProgressMembers;
          _loadingMembers = false;
        });
      } else {
        final completedMembers = await _memberBadgeProvider
            .getMembersByBadgeStatus(widget.badge.id, 1);

        final inProgressMembers = await _memberBadgeProvider
            .getMembersByBadgeStatus(widget.badge.id, 0);

        setState(() {
          _completedMembers = completedMembers;
          _inProgressMembers = inProgressMembers;
          _loadingMembers = false;
        });
      }

      if (widget.role == 'Admin') {
        await _loadMemberTroopNames();
      }
    } catch (e) {
      showErrorSnackbar(context, e);
      setState(() {
        _loadingMembers = false;
      });
    }
  }

  Future<void> _loadMemberTroopNames() async {
    try {
      final filter = {'RetrieveAll': true};
      final troopResult = await _troopProvider.get(filter: filter);

      if (!mounted) return;

      final memberProvider = MemberProvider(_memberBadgeProvider.authProvider);
      final memberFilter = {'RetrieveAll': true};
      final memberResult = await memberProvider.get(filter: memberFilter);

      if (!mounted) return;

      final memberTroopNames = <int, String>{};

      for (final member in memberResult.items ?? []) {
        final troop = troopResult.items?.firstWhere(
          (troop) => troop.id == member.troopId,
        );
        if (troop != null) {
          memberTroopNames[member.id] = troop.name;
        }
      }

      setState(() {
        _memberTroopNames = memberTroopNames;
      });
    } catch (e) {
      print('Error loading member troop names: $e');
    }
  }

  void _showAddRequirementDialog() {
    if (_requirements.length >= 20) {
      showErrorSnackbar(
        context,
        'Dostignut je maksimalan broj uslova (20). Nije moguće dodati nove uslove.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => BadgeRequirementFormDialog(
        badgeId: widget.badge.id,
        onRequirementAdded: _loadRequirements,
      ),
    );
  }

  void _showEditRequirementDialog(BadgeRequirement requirement) {
    showDialog(
      context: context,
      builder: (context) => BadgeRequirementFormDialog(
        badgeId: widget.badge.id,
        requirement: requirement,
        onRequirementAdded: _loadRequirements,
      ),
    );
  }

  Future<void> _deleteRequirement(BadgeRequirement requirement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati uslov "${requirement.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _badgeRequirementProvider.delete(requirement.id);
        _loadRequirements();
        if (mounted) {
          showSuccessSnackbar(context, 'Uslov je uspješno obrisan');
        }
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _showMemberBadgeProgressDialog(MemberBadge memberBadge) {
    showDialog(
      context: context,
      builder: (context) => MemberBadgeProgressDialog(
        memberBadge: memberBadge,
        badge: widget.badge,
        role: widget.role,
        loggedInUserId: widget.loggedInUserId,
        onProgressUpdated: _loadMembers,
      ),
    );
  }

  void _showCreateMemberBadgeDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMemberBadgeDialog(
        badge: widget.badge,
        role: widget.role,
        onMemberBadgeCreated: _loadMembers,
      ),
    );
  }

  void _showAllCompletedMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberBadgeListScreen(
          badgeId: widget.badge.id,
          initialStatus: 1, // Completed
        ),
      ),
    );
  }

  void _showAllInProgressMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberBadgeListScreen(
          badgeId: widget.badge.id,
          initialStatus: 0, // InProgress
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: widget.role,
      selectedMenu: 'Vještarstva',
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  widget.badge.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 4,
                                ),
                              ),
                              child: widget.badge.imageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        widget.badge.imageUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.emoji_events,
                                                color: Colors.amber,
                                                size: 60,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber,
                                      size: 60,
                                    ),
                            ),

                            const SizedBox(width: 24),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.badge.description.isNotEmpty) ...[
                                    Text(
                                      'Opis:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.badge.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  Text(
                                    'Kreirano: ${formatDateTime(widget.badge.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  if (widget.badge.updatedAt != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ažurirano: ${formatDateTime(widget.badge.updatedAt!)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Uslovi za vještarstvo:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  '${_requirements.length}/20',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _requirements.length >= 18
                                        ? Colors.orange
                                        : _requirements.length >= 15
                                        ? Colors.blue
                                        : Colors.grey.shade600,
                                    fontWeight: _requirements.length >= 18
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.role == 'Admin')
                              ElevatedButton.icon(
                                onPressed: _requirements.length >= 20
                                    ? null
                                    : _showAddRequirementDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Dodaj uslov'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (_requirements.length >= 20)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Dostignut je maksimalan broj uslova (20). Nije moguće dodati nove uslove.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_requirements.length >= 20)
                          const SizedBox(height: 8),

                        if (_requirements.length >= 15 &&
                            _requirements.length < 20)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Približavate se maksimalnom broju uslova. Preostalo: ${20 - _requirements.length} uslova.',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_requirements.length >= 15 &&
                            _requirements.length < 20)
                          const SizedBox(height: 8),

                        if (_loadingRequirements)
                          const Center(child: CircularProgressIndicator())
                        else if (_requirements.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nema definisanih uslova za ovo vještarstvo.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      thickness: 6,
                                      radius: const Radius.circular(3),
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _requirements.length,
                                        itemBuilder: (context, index) {
                                          final requirement =
                                              _requirements[index];
                                          return Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                requirement.description,
                                              ),
                                              subtitle: Text(
                                                'Kreirano: ${formatDateTime(requirement.createdAt)}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              trailing: widget.role == 'Admin'
                                                  ? Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              _showEditRequirementDialog(
                                                                requirement,
                                                              ),
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                          ),
                                                          tooltip: 'Uredi',
                                                        ),
                                                        IconButton(
                                                          onPressed: () =>
                                                              _deleteRequirement(
                                                                requirement,
                                                              ),
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            size: 20,
                                                          ),
                                                          tooltip: 'Obriši',
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    )
                                                  : null,
                                            ),
                                          );
                                        },
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
              ),

              const SizedBox(width: 24),

              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Završili',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (widget.role == 'Troop') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: Colors.blue.shade700,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vaši članovi',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _showAllCompletedMembers(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Prikaži više',
                                  style: TextStyle(
                                    color: Colors.green,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: _loadingMembers
                              ? const Center(child: CircularProgressIndicator())
                              : _completedMembers.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Nema članova koji su završili ovo vještarstvo.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _completedMembers.length > 4
                              ? Scrollbar(
                                  controller: _completedMembersScrollController,
                                  thumbVisibility: true,
                                  thickness: 6,
                                  radius: const Radius.circular(3),
                                  child: GridView.builder(
                                    controller:
                                        _completedMembersScrollController,
                                    primary: false,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    itemCount: _completedMembers.length,
                                    itemBuilder: (context, index) {
                                      final member = _completedMembers[index];
                                      return HoverableMemberCard(
                                        member: member,
                                        onTap: () =>
                                            _showMemberBadgeProgressDialog(
                                              member,
                                            ),
                                        role: widget.role,
                                        troopName:
                                            _memberTroopNames[member.memberId],
                                      );
                                    },
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: _completedMembers.length,
                                  itemBuilder: (context, index) {
                                    final member = _completedMembers[index];
                                    return HoverableMemberCard(
                                      member: member,
                                      onTap: () =>
                                          _showMemberBadgeProgressDialog(
                                            member,
                                          ),
                                      role: widget.role,
                                      troopName:
                                          _memberTroopNames[member.memberId],
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Text(
                              'U toku',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (widget.role == 'Troop') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: Colors.blue.shade700,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vaši članovi',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _showAllInProgressMembers(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Prikaži više',
                                  style: TextStyle(
                                    color: Colors.green,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.role != 'Member')
                              TextButton.icon(
                                onPressed: _showCreateMemberBadgeDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Dodaj člana'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: _loadingMembers
                              ? const Center(child: CircularProgressIndicator())
                              : _inProgressMembers.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Nema članova koji rade na ovom vještarstvu.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _inProgressMembers.length > 4
                              ? Scrollbar(
                                  controller:
                                      _inProgressMembersScrollController,
                                  thumbVisibility: true,
                                  thickness: 6,
                                  radius: const Radius.circular(3),
                                  child: GridView.builder(
                                    controller:
                                        _inProgressMembersScrollController,
                                    primary: false,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    itemCount: _inProgressMembers.length,
                                    itemBuilder: (context, index) {
                                      final member = _inProgressMembers[index];
                                      return HoverableMemberCard(
                                        member: member,
                                        onTap: () =>
                                            _showMemberBadgeProgressDialog(
                                              member,
                                            ),
                                        role: widget.role,
                                        troopName:
                                            _memberTroopNames[member.memberId],
                                      );
                                    },
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: _inProgressMembers.length,
                                  itemBuilder: (context, index) {
                                    final member = _inProgressMembers[index];
                                    return HoverableMemberCard(
                                      member: member,
                                      onTap: () =>
                                          _showMemberBadgeProgressDialog(
                                            member,
                                          ),
                                      role: widget.role,
                                      troopName:
                                          _memberTroopNames[member.memberId],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgeRequirementFormDialog extends StatefulWidget {
  final int badgeId;
  final BadgeRequirement? requirement;
  final VoidCallback onRequirementAdded;

  const BadgeRequirementFormDialog({
    super.key,
    required this.badgeId,
    this.requirement,
    required this.onRequirementAdded,
  });

  @override
  State<BadgeRequirementFormDialog> createState() =>
      _BadgeRequirementFormDialogState();
}

class _BadgeRequirementFormDialogState
    extends State<BadgeRequirementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.requirement != null) {
      _descriptionController.text = widget.requirement!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRequirement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requirementProvider = BadgeRequirementProvider(authProvider);

      if (widget.requirement == null) {
        await requirementProvider.create(
          badgeId: widget.badgeId,
          description: _descriptionController.text.trim(),
        );
        if (mounted) {
          showSuccessSnackbar(context, 'Uslov je uspješno kreiran');
        }
      } else {
        await requirementProvider.updateBadgeRequirement(
          id: widget.requirement!.id,
          badgeId: widget.badgeId,
          description: _descriptionController.text.trim(),
        );
        if (mounted) {
          showSuccessSnackbar(context, 'Uslov je uspješno ažuriran');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRequirementAdded();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.requirement != null;

    return AlertDialog(
      title: Text(isEditing ? 'Uredi uslov' : 'Dodaj novi uslov'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Opis uslova *',
                  border: OutlineInputBorder(),
                  helperText: 'Maksimalno 500 znakova',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Opis je obavezan';
                  }
                  if (value.trim().length > 500) {
                    return 'Opis ne smije biti duži od 500 znakova';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {});
                  }
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_descriptionController.text.length}/500',
                    style: TextStyle(
                      fontSize: 12,
                      color: _descriptionController.text.length > 450
                          ? Colors.orange
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              if (!isEditing) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Maksimalan broj uslova po vještarstvu je 20.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: _isLoading ? null : _saveRequirement,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Ažuriraj' : 'Kreiraj'),
        ),
      ],
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
          showErrorSnackbar(
            context,
            'Greška: Nije moguće učitati podatke o članu "${widget.memberBadge.memberFullName}"',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

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
      await _progressProvider.updateCompletion(progress.id, isCompleted);

      setState(() {
        final index = _progressList.indexWhere((p) => p.id == progress.id);
        if (index != -1) {
          _progressList[index] = MemberBadgeProgress(
            id: progress.id,
            memberBadgeId: progress.memberBadgeId,
            requirementId: progress.requirementId,
            requirementDescription: progress.requirementDescription,
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
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
        showSuccessSnackbar(context, 'Vještarstvo je uspješno dodijeljeno');
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
        showSuccessSnackbar(
          context,
          'Vještarstvo je vraćeno u status "U toku"',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
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
          showSuccessSnackbar(
            context,
            'Član je uspješno obrisan iz vještarstva',
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

  bool get _hasProgressRecords {
    return _progressList.isNotEmpty;
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
                                decorationColor: Colors.blue,
                                decorationThickness: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.blue,
                              size: 16,
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
            else if (!_hasProgressRecords)
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
                      'Nema zapisanog napretka za ovo vještarstvo. Provjerite da li postoje uslovi za vještarstvo.',
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
                widget.memberBadge.status != 1 &&
                _hasProgressRecords)
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
            const SizedBox(height: 12),
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

class CreateMemberBadgeDialog extends StatefulWidget {
  final Badge badge;
  final String role;
  final VoidCallback onMemberBadgeCreated;

  const CreateMemberBadgeDialog({
    super.key,
    required this.badge,
    required this.role,
    required this.onMemberBadgeCreated,
  });

  @override
  State<CreateMemberBadgeDialog> createState() =>
      _CreateMemberBadgeDialogState();
}

class _CreateMemberBadgeDialogState extends State<CreateMemberBadgeDialog> {
  List<Member> _members = [];
  bool _loading = false;
  bool _creating = false;
  Member? _selectedMember;

  late MemberProvider _memberProvider;
  late MemberBadgeProvider _memberBadgeProvider;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _memberProvider = MemberProvider(authProvider);
    _memberBadgeProvider = MemberBadgeProvider(authProvider);
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
    });

    try {
      if (widget.role == 'Troop') {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final troopId = await authProvider.getUserIdFromToken() ?? 0;

        final filter = {'TroopId': troopId, 'RetrieveAll': true};
        final result = await _memberProvider.get(filter: filter);

        final allMembers = result.items ?? [];
        final membersWithoutBadge = <Member>[];

        final completedMembers = await _memberBadgeProvider
            .getMembersByBadgeStatusAndTroop(widget.badge.id, 1, troopId);
        final inProgressMembers = await _memberBadgeProvider
            .getMembersByBadgeStatusAndTroop(widget.badge.id, 0, troopId);

        final memberIdsWithBadge = <int>{};
        for (final mb in completedMembers) {
          memberIdsWithBadge.add(mb.memberId);
        }
        for (final mb in inProgressMembers) {
          memberIdsWithBadge.add(mb.memberId);
        }

        for (final member in allMembers) {
          if (!memberIdsWithBadge.contains(member.id)) {
            membersWithoutBadge.add(member);
          }
        }

        setState(() {
          _members = membersWithoutBadge;
          _loading = false;
        });
      } else {
        final filter = {'RetrieveAll': true};
        final result = await _memberProvider.get(filter: filter);

        final allMembers = result.items ?? [];
        final membersWithoutBadge = <Member>[];

        final completedMembers = await _memberBadgeProvider
            .getMembersByBadgeStatus(widget.badge.id, 1);
        final inProgressMembers = await _memberBadgeProvider
            .getMembersByBadgeStatus(widget.badge.id, 0);

        final memberIdsWithBadge = <int>{};
        for (final mb in completedMembers) {
          memberIdsWithBadge.add(mb.memberId);
        }
        for (final mb in inProgressMembers) {
          memberIdsWithBadge.add(mb.memberId);
        }

        for (final member in allMembers) {
          if (!memberIdsWithBadge.contains(member.id)) {
            membersWithoutBadge.add(member);
          }
        }

        setState(() {
          _members = membersWithoutBadge;
          _loading = false;
        });
      }
    } catch (e) {
      showErrorSnackbar(context, e);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createMemberBadge() async {
    if (_selectedMember == null) return;

    setState(() {
      _creating = true;
    });

    try {
      await _memberBadgeProvider.createMemberBadge(
        _selectedMember!.id,
        widget.badge.id,
      );

      if (widget.role == 'Troop') {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final troopId = await authProvider.getUserIdFromToken() ?? 0;
        await _memberBadgeProvider.syncProgressRecordsForBadgeAndTroop(
          widget.badge.id,
          troopId,
        );
      } else {
        await _memberBadgeProvider.syncProgressRecordsForBadge(widget.badge.id);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onMemberBadgeCreated();
        showSuccessSnackbar(
          context,
          'Vještarstvo je uspješno dodijeljeno članu',
        );
      }
    } catch (e) {
      showErrorSnackbar(context, e);
      setState(() {
        _creating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dodijeli vještarstvo članu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Odaberite člana koji želi započeti rad na vještarstvu "${widget.badge.name}":',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_members.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Svi članovi već imaju ovo vještarstvo ili su već dodijeljeni.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        backgroundImage: member.profilePictureUrl.isNotEmpty
                            ? NetworkImage(member.profilePictureUrl)
                            : null,
                        child: member.profilePictureUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(member.firstName + ' ' + member.lastName),
                      subtitle: Text(member.email),
                      trailing: Radio<Member>(
                        value: member,
                        groupValue: _selectedMember,
                        onChanged: (value) {
                          setState(() {
                            _selectedMember = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMember = member;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Odustani'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _selectedMember == null || _creating
                      ? null
                      : _createMemberBadge,
                  child: _creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Dodijeli'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HoverableMemberCard extends StatefulWidget {
  final MemberBadge member;
  final VoidCallback onTap;
  final String role;
  final String? troopName;

  const HoverableMemberCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.role,
    this.troopName,
  });

  @override
  State<HoverableMemberCard> createState() => _HoverableMemberCardState();
}

class _HoverableMemberCardState extends State<HoverableMemberCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? Colors.green : Colors.grey.shade300,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.shade300,
                blurRadius: _isHovered ? 4 : 2,
                offset: Offset(0, _isHovered ? 2 : 1),
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade400,
                backgroundImage:
                    widget.member.memberProfilePictureUrl.isNotEmpty
                    ? NetworkImage(widget.member.memberProfilePictureUrl)
                    : null,
                child: widget.member.memberProfilePictureUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                widget.member.memberFullName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
                  color: _isHovered ? Colors.green : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.role == 'Admin' && widget.troopName != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.troopName!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
