import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../models/friendship.dart';
import '../providers/member_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friendship_provider.dart';
import '../layouts/master_screen.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'profile_screen.dart';

class MemberListScreen extends StatefulWidget {
  final int? troopId;
  final String title;
  final bool showFriends;
  final List<Member>? filteredFriends;

  const MemberListScreen({
    super.key,
    this.troopId,
    required this.title,
    this.showFriends = false,
    this.filteredFriends,
  });

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  List<Friendship> _friendships = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentUserId;
  late FriendshipProvider _friendshipProvider;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Sve kategorije';
  String _selectedCity = 'Svi gradovi';
  String _selectedGender = 'Svi spolovi';
  String _selectedTroop = 'Svi odredi';
  List<String> _availableCategories = ['Sve kategorije'];
  List<String> _availableCities = ['Svi gradovi'];
  List<String> _availableTroops = ['Svi odredi'];

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _friendshipProvider = FriendshipProvider(authProvider);

      final userInfo = await authProvider.getCurrentUserInfo();
      final currentUserId = userInfo?['id'] as int?;

      if (widget.filteredFriends != null) {
        final friendships = <Friendship>[];
        if (currentUserId != null) {
          try {
            final friendsResult = await _friendshipProvider.getMyFriends();
            final pendingResult = await _friendshipProvider
                .getPendingRequests();
            final sentResult = await _friendshipProvider.getSentRequests();

            friendships.addAll(friendsResult.items ?? []);
            friendships.addAll(pendingResult.items ?? []);
            friendships.addAll(sentResult.items ?? []);
          } catch (e) {
            // Continue without friendship data if there's an error
          }
        }

        if (mounted) {
          setState(() {
            _members = widget.filteredFriends!;
            _friendships = friendships;
            _currentUserId = currentUserId;
            _isLoading = false;
          });

          _populateFilterOptions();
          _applyFilters();
        }
      } else if (widget.showFriends) {
        final friendsResult = await _friendshipProvider.getMyFriends();
        final friendships = friendsResult.items ?? [];

        final friendIds = <int>{};
        for (final friendship in friendships) {
          if (friendship.requesterId == currentUserId) {
            friendIds.add(friendship.responderId);
          } else {
            friendIds.add(friendship.requesterId);
          }
        }

        final members = <Member>[];
        for (final friendId in friendIds) {
          try {
            final member = await memberProvider.getById(friendId);
            members.add(member);
          } catch (e) {
            // Skip if member not found
          }
        }

        if (mounted) {
          setState(() {
            _members = members;
            _friendships = friendships;
            _currentUserId = currentUserId;
            _isLoading = false;
          });

          _populateFilterOptions();
          _applyFilters();
        }
      } else {
        final filter = {'TroopId': widget.troopId, 'RetrieveAll': true};
        final result = await memberProvider.get(filter: filter);

        final friendships = <Friendship>[];
        if (currentUserId != null) {
          try {
            final friendsResult = await _friendshipProvider.getMyFriends();
            final pendingResult = await _friendshipProvider
                .getPendingRequests();
            final sentResult = await _friendshipProvider.getSentRequests();

            friendships.addAll(friendsResult.items ?? []);
            friendships.addAll(pendingResult.items ?? []);
            friendships.addAll(sentResult.items ?? []);
          } catch (e) {
            // Continue without friendship data if there's an error
          }
        }

        if (mounted) {
          setState(() {
            _members = result.items ?? [];
            _currentUserId = currentUserId;
            _friendships = friendships;
            _isLoading = false;
          });

          _populateFilterOptions();
          _applyFilters();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
        });
      }
    }
  }

  void _populateFilterOptions() {
    final categories = _members
        .map((member) => member.categoryName)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    _availableCategories = ['Sve kategorije', ...categories];

    final cities = _members
        .map((member) => member.cityName)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    _availableCities = ['Svi gradovi', ...cities];

    final troops = _members
        .map((member) => member.troopName)
        .where((troop) => troop.isNotEmpty)
        .toSet()
        .toList();
    troops.sort();
    _availableTroops = ['Svi odredi', ...troops];
  }

  void _applyFilters() {
    setState(() {
      _filteredMembers = _members.where((member) {
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase().trim();
          final firstName = member.firstName.toLowerCase();
          final lastName = member.lastName.toLowerCase();
          final username = member.username.toLowerCase();

          if (!firstName.contains(searchLower) &&
              !lastName.contains(searchLower) &&
              !username.contains(searchLower)) {
            return false;
          }
        }

        if (_selectedCategory != 'Sve kategorije') {
          if (member.categoryName != _selectedCategory) {
            return false;
          }
        }

        if (_selectedCity != 'Svi gradovi') {
          if (member.cityName != _selectedCity) {
            return false;
          }
        }

        if (_selectedGender != 'Svi spolovi') {
          if (_selectedGender == 'Muški' && member.gender != 0) {
            return false;
          }
          if (_selectedGender == 'Ženski' && member.gender != 1) {
            return false;
          }
        }

        if (widget.troopId == null && _selectedTroop != 'Svi odredi') {
          if (member.troopName != _selectedTroop) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  String _getFriendshipStatus(int memberId) {
    if (_currentUserId == null) return 'none';

    for (final friendship in _friendships) {
      if ((friendship.requesterId == _currentUserId &&
              friendship.responderId == memberId) ||
          (friendship.requesterId == memberId &&
              friendship.responderId == _currentUserId)) {
        if (friendship.status == 'Accepted') {
          return 'friend';
        } else if (friendship.status == 'Pending') {
          if (friendship.requesterId == _currentUserId) {
            return 'pending_sent';
          } else {
            return 'pending_received';
          }
        }
      }
    }

    return 'none';
  }

  Future<void> _onAddFriend(Member member) async {
    if (_currentUserId == null) return;

    final confirmed = await _showSendRequestConfirmationDialog(member);
    if (!confirmed) return;

    try {
      await _friendshipProvider.sendFriendRequest(member.id);
      SnackBarUtils.showSuccessSnackBar(
        'Zahtjev za prijateljstvo je poslan',
        context: context,
      );
      await _loadMembers();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar(
        'Greška pri slanju zahtjeva: $e',
        context: context,
      );
    }
  }

  Future<bool> _showSendRequestConfirmationDialog(Member member) async {
    final memberName = '${member.firstName} ${member.lastName}';

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Pošalji zahtjev za prijateljstvo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Da li ste sigurni da želite poslati zahtjev za prijateljstvo korisniku $memberName?',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text(
                        'Otkaži',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Pošalji',
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
        ) ??
        false;
  }

  void _onMemberTap(Member member) {
    if (_currentUserId != null && member.id == _currentUserId) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      _showMemberOptionsModal(member);
    }
  }

  void _showMemberOptionsModal(Member member) {
    final friendshipStatus = _getFriendshipStatus(member.id);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  backgroundImage: member.profilePictureUrl.isNotEmpty
                      ? NetworkImage(
                          UrlUtils.buildImageUrl(member.profilePictureUrl),
                          headers: const {
                            'User-Agent': 'ScoutTrack Mobile App',
                          },
                        )
                      : null,
                  child: member.profilePictureUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 30,
                          color: const Color(0xFF2E7D32),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${member.firstName} ${member.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (member.categoryName.isNotEmpty)
                        Text(
                          member.categoryName,
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
            const SizedBox(height: 16),
            ..._buildFriendshipActions(member, friendshipStatus),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFriendshipActions(Member member, String friendshipStatus) {
    List<Widget> actions = [];

    actions.add(
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Pogledaj profil'),
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(memberId: member.id),
            ),
          );
        },
      ),
    );

    switch (friendshipStatus) {
      case 'friend':
        actions.add(
          ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.red),
            title: const Text('Ukloni prijatelja'),
            onTap: () {
              Navigator.pop(context);
              _showUnfriendDialog(member);
            },
          ),
        );
        break;

      case 'pending_sent':
        actions.add(
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.orange),
            title: const Text('Otkaži zahtjev'),
            onTap: () {
              Navigator.pop(context);
              _showCancelRequestDialog(member);
            },
          ),
        );
        break;

      case 'pending_received':
        actions.addAll([
          ListTile(
            leading: const Icon(Icons.check, color: Colors.green),
            title: const Text('Prihvati zahtjev'),
            onTap: () {
              Navigator.pop(context);
              _showAcceptRequestDialog(member);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.red),
            title: const Text('Odbij zahtjev'),
            onTap: () {
              Navigator.pop(context);
              _showRejectRequestDialog(member);
            },
          ),
        ]);
        break;

      case 'none':
      default:
        actions.add(
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.green),
            title: const Text('Dodaj prijatelja'),
            onTap: () {
              Navigator.pop(context);
              _onAddFriend(member);
            },
          ),
        );
        break;
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: widget.title,
      selectedIndex: -1,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Greška pri učitavanju članova',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMembers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Nema članova u ovom odredu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Članovi će se prikazati kada se pridruže odredu',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembers,
      color: const Color(0xFF2E7D32),
      child: _filteredMembers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return _buildMemberCard(member);
              },
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pretraži članove...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _showFilters ? Colors.blue : Colors.grey,
                ),
                tooltip: _showFilters ? 'Sakrij filtere' : 'Prikaži filtere',
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            _buildFilterControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategorija',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _availableCategories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'Grad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _availableCities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.troopId == null)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Spol',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const ['Svi spolovi', 'Muški', 'Ženski'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTroop,
                  decoration: InputDecoration(
                    labelText: 'Odred',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _availableTroops.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTroop = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Spol',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: const ['Svi spolovi', 'Muški', 'Ženski'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
              _applyFilters();
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasFilters =
        _searchController.text.isNotEmpty ||
        _selectedCategory != 'Sve kategorije' ||
        _selectedCity != 'Svi gradovi' ||
        _selectedGender != 'Svi spolovi' ||
        (widget.troopId == null && _selectedTroop != 'Svi odredi');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Nema rezultata' : 'Nema članova',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Nema članova koji odgovaraju filterima'
                : 'Ovaj odred nema članova',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = 'Sve kategorije';
                  _selectedCity = 'Svi gradovi';
                  _selectedGender = 'Svi spolovi';
                  if (widget.troopId == null) {
                    _selectedTroop = 'Svi odredi';
                  }
                });
                _applyFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Očisti filtere'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _onMemberTap(member),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          backgroundImage: member.profilePictureUrl.isNotEmpty
              ? NetworkImage(
                  UrlUtils.buildImageUrl(member.profilePictureUrl),
                  headers: const {'User-Agent': 'ScoutTrack Mobile App'},
                )
              : null,
          child: member.profilePictureUrl.isEmpty
              ? Icon(Icons.person, size: 24, color: const Color(0xFF2E7D32))
              : null,
        ),
        title: Text(
          '${member.firstName} ${member.lastName}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: member.categoryName.isNotEmpty
            ? Text(
                member.categoryName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              )
            : null,
        trailing: widget.showFriends ? null : _buildAddFriendButton(member),
      ),
    );
  }

  Widget _buildAddFriendButton(Member member) {
    if (_currentUserId == null || member.id == _currentUserId) {
      return const SizedBox.shrink();
    }

    final friendshipStatus = _getFriendshipStatus(member.id);

    switch (friendshipStatus) {
      case 'friend':
        return Tooltip(
          message: 'Prijatelji',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people, color: Colors.white, size: 24),
          ),
        );
      case 'pending_sent':
        return Tooltip(
          message: 'Zahtjev poslan',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      case 'pending_received':
        return Tooltip(
          message: 'Zahtjev primljen',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 24),
          ),
        );
      case 'none':
      default:
        return Tooltip(
          message: 'Dodaj prijatelja',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white, size: 24),
              onPressed: () => _onAddFriend(member),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        );
    }
  }

  void _showUnfriendDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ukloni prijatelja',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Da li ste sigurni da želite ukloniti ${member.firstName} ${member.lastName} iz prijatelja?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _unfriend(member);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Ukloni',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _unfriend(Member member) async {
    try {
      final friendship = _friendships.firstWhere(
        (f) =>
            (f.requesterId == _currentUserId && f.responderId == member.id) ||
            (f.responderId == _currentUserId && f.requesterId == member.id),
      );

      final success = await _friendshipProvider.unfriend(friendship.id);
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Prijatelj je uklonjen',
          context: context,
        );
        await _loadMembers();
      } else {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri uklanjanju prijatelja',
          context: context,
        );
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e', context: context);
    }
  }

  void _showAcceptRequestDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Prihvati zahtjev za prijateljstvo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Da li ste sigurni da želite prihvatiti zahtjev za prijateljstvo od ${member.firstName} ${member.lastName}?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _acceptFriendRequest(member);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Prihvati',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectRequestDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Odbij zahtjev za prijateljstvo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Da li ste sigurni da želite odbiti zahtjev za prijateljstvo od ${member.firstName} ${member.lastName}?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _rejectFriendRequest(member);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Odbij',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelRequestDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Otkaži zahtjev za prijateljstvo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Da li ste sigurni da želite otkazati zahtjev za prijateljstvo za ${member.firstName} ${member.lastName}?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Otkaži', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _cancelFriendRequest(member);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Otkaži zahtjev',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptFriendRequest(Member member) async {
    try {
      final friendship = _friendships.firstWhere(
        (f) => f.requesterId == member.id && f.responderId == _currentUserId,
      );

      final success = await _friendshipProvider.acceptFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je prihvaćen',
          context: context,
        );
        await _loadMembers();
      } else {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri prihvatanju zahtjeva',
          context: context,
        );
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e', context: context);
    }
  }

  Future<void> _rejectFriendRequest(Member member) async {
    try {
      final friendship = _friendships.firstWhere(
        (f) => f.requesterId == member.id && f.responderId == _currentUserId,
      );

      final success = await _friendshipProvider.rejectFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je odbačen',
          context: context,
        );
        await _loadMembers();
      } else {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri odbacivanju zahtjeva',
          context: context,
        );
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e', context: context);
    }
  }

  Future<void> _cancelFriendRequest(Member member) async {
    try {
      final friendship = _friendships.firstWhere(
        (f) => f.requesterId == _currentUserId && f.responderId == member.id,
      );

      final success = await _friendshipProvider.cancelFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je otkazan',
          context: context,
        );
        await _loadMembers();
      } else {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri otkazivanju zahtjeva',
          context: context,
        );
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e', context: context);
    }
  }
}
