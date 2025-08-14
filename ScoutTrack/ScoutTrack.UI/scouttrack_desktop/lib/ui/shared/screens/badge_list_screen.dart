import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/badge_provider.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/badge_form_dialog.dart';
import 'package:scouttrack_desktop/ui/shared/screens/badge_details_screen.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';

class BadgeListScreen extends StatefulWidget {
  const BadgeListScreen({super.key});

  @override
  State<BadgeListScreen> createState() => _BadgeListScreenState();
}

class _BadgeListScreenState extends State<BadgeListScreen> {
  SearchResult<Badge>? _badges;
  bool _loading = false;
  String? _role;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late BadgeProvider _badgeProvider;

  int currentPage = 0;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _badgeProvider = BadgeProvider(authProvider);
    _loadInitialData();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = await authProvider.getUserRole();
    setState(() {
      _role = role;
    });

    await _fetchBadges();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 0;
      });
      _fetchBadges();
    });
  }

  Future<void> _fetchBadges({int? page}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      final filter = {
        'Page': page ?? currentPage,
        'PageSize': pageSize,
        'IncludeTotalCount': true,
        'FTS': searchController.text.isEmpty ? null : searchController.text,
      };

      final result = await _badgeProvider.get(filter: filter);
      setState(() {
        _badges = result as SearchResult<Badge>;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        _loading = false;
      });
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  void _goToPage(int page) {
    setState(() {
      currentPage = page;
    });
    _fetchBadges(page: page);
  }

  void _showBadgeDetails(Badge badge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BadgeDetailsScreen(
          badge: badge,
          role: _role ?? 'Troop',
          loggedInUserId: 0, // Not used in current implementation
        ),
      ),
    );
  }

  void _showAddBadgeDialog() {
    showDialog(
      context: context,
      builder: (context) => const BadgeFormDialog(),
    ).then((_) => _fetchBadges());
  }

  void _showEditBadgeDialog(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeFormDialog(badge: badge),
    ).then((_) => _fetchBadges());
  }

  Future<void> _deleteBadge(Badge badge) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati vještarstvo "${badge.name}"?',
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
        await _badgeProvider.delete(badge.id);
        _fetchBadges();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vještarstvo "${badge.name}" je uspješno obrisano',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showErrorSnackbar(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? 'Troop',
      selectedMenu: 'Vještarstva',
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 400,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Pretraži...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_role == 'Admin')
                    ElevatedButton.icon(
                      onPressed: _showAddBadgeDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Dodaj novo vještarstvo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8055),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_badges?.items?.isEmpty ?? true)
                    ? const Center(
                        child: Text(
                          'Nema pronađenih vještarstava',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _badges?.items?.length ?? 0,
                              itemBuilder: (context, index) {
                                final badge = _badges!.items![index];
                                return _buildBadgeCard(badge);
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                          PaginationControls(
                            currentPage:
                                currentPage +
                                1,
                            totalPages: totalPages,
                            totalCount: _badges?.totalCount ?? 0,
                            onPageChanged: (page) =>
                                _goToPage(page - 1),
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

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBadgeDetails(badge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: badge.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          badge.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 35,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 35,
                      ),
              ),
              const SizedBox(height: 12),

              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (_role == 'Admin') ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _showEditBadgeDialog(badge),
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Uredi',
                    ),
                    IconButton(
                      onPressed: () => _deleteBadge(badge),
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: 'Obriši',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
