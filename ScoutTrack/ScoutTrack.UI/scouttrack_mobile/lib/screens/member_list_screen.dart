import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../providers/auth_provider.dart';
import '../layouts/master_screen.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'profile_screen.dart';

class MemberListScreen extends StatefulWidget {
  final int troopId;
  final String title;

  const MemberListScreen({
    super.key,
    required this.troopId,
    required this.title,
  });

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Sve kategorije';
  String _selectedCity = 'Svi gradovi';
  String _selectedGender = 'Svi spolovi';
  List<String> _availableCategories = ['Sve kategorije'];
  List<String> _availableCities = ['Svi gradovi'];

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

      final userInfo = await authProvider.getCurrentUserInfo();
      final currentUserId = userInfo?['id'] as int?;

      final filter = {'TroopId': widget.troopId, 'RetrieveAll': true};

      final result = await memberProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _members = result.items ?? [];
          _currentUserId = currentUserId;
          _isLoading = false;
        });

        _populateFilterOptions();
        _applyFilters();
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

        return true;
      }).toList();
    });
  }

  void _onAddFriend(Member member) {
    // TODO: Implement friendship functionality
    SnackBarUtils.showInfoSnackBar(
      'Dodavanje prijatelja - funkcionalnost u razvoju',
      context: context,
    );
  }

  void _onMemberTap(Member member) {
    if (_currentUserId != null && member.id == _currentUserId) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(memberId: member.id),
        ),
      );
    }
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
          TextField(
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
          const SizedBox(height: 12),

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
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters =
        _searchController.text.isNotEmpty ||
        _selectedCategory != 'Sve kategorije' ||
        _selectedCity != 'Svi gradovi' ||
        _selectedGender != 'Svi spolovi';

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
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            onPressed: () => _onAddFriend(member),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ),
    );
  }
}
