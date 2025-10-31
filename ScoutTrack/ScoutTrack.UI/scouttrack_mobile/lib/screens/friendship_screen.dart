import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/friendship_provider.dart';
import '../providers/member_provider.dart';
import '../providers/city_provider.dart';
import '../providers/troop_provider.dart';
import '../models/friendship.dart';
import '../models/friend_recommendation.dart';
import '../models/member.dart';
import '../models/city.dart';
import '../models/troop.dart';
import '../models/search_result.dart';
import '../utils/snackbar_utils.dart';
import '../utils/url_utils.dart';
import 'member_list_screen.dart';
import 'profile_screen.dart';

class FriendshipScreen extends StatefulWidget {
  const FriendshipScreen({super.key});

  @override
  State<FriendshipScreen> createState() => _FriendshipScreenState();
}

class _FriendshipScreenState extends State<FriendshipScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late FriendshipProvider _friendshipProvider;
  late MemberProvider _memberProvider;
  late CityProvider _cityProvider;
  late TroopProvider _troopProvider;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  SearchResult<Friendship>? _myFriends;
  SearchResult<Friendship>? _pendingRequests;
  SearchResult<Friendship>? _sentRequests;
  List<FriendRecommendation> _recommendations = [];
  Set<int> _sentRequestUserIds = {};

  bool _loadingFriends = false;
  bool _loadingPending = false;
  bool _loadingSent = false;
  bool _loadingRecommendations = false;

  String? _error;
  int? _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  List<Member> _allFriends = [];
  List<Member> _filteredFriends = [];
  List<City> _cities = [];
  List<Troop> _troops = [];
  List<String> _availableCategories = ['Sve kategorije'];

  String _selectedCity = 'Svi gradovi';
  String _selectedTroop = 'Svi odredi';
  String _selectedGender = 'Svi spolovi';
  String _selectedCategory = 'Sve kategorije';

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SnackBarUtils.initialize(_scaffoldMessengerKey);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadRecommendations();
    }
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userInfo = await authProvider.getCurrentUserInfo();
    _currentUserId = userInfo?['id'] as int?;

    _friendshipProvider = FriendshipProvider(authProvider);
    _memberProvider = MemberProvider(authProvider);
    _cityProvider = CityProvider(authProvider);
    _troopProvider = TroopProvider(authProvider);

    await Future.wait([
      _loadFilterData(),
      _loadMyFriends(),
      _loadPendingRequests(),
      _loadSentRequests(),
    ]);

    await _loadRecommendations();
  }

  Future<void> _loadFilterData() async {
    try {
      final futures = await Future.wait([
        _cityProvider.get(filter: {"RetrieveAll": true}),
        _troopProvider.get(filter: {"RetrieveAll": true}),
      ]);

      final cityResult = futures[0] as SearchResult<City>;
      final troopResult = futures[1] as SearchResult<Troop>;

      if (mounted) {
        setState(() {
          _cities = cityResult.items ?? [];
          _troops = troopResult.items ?? [];
        });
      }
    } catch (e) {
      print('Error loading filter data: $e');
    }
  }

  Future<void> _loadMyFriends() async {
    if (_loadingFriends) return;

    setState(() {
      _loadingFriends = true;
      _error = null;
    });

    try {
      final result = await _friendshipProvider.getMyFriends();
      final friendships = result.items ?? [];

      final friendIds = <int>{};
      for (final friendship in friendships) {
        if (friendship.requesterId == _currentUserId) {
          friendIds.add(friendship.responderId);
        } else {
          friendIds.add(friendship.requesterId);
        }
      }

      final members = <Member>[];
      for (final friendId in friendIds) {
        try {
          final member = await _memberProvider.getById(friendId);
          members.add(member);
        } catch (e) {
          // Skip if member not found
        }
      }

      if (mounted) {
        setState(() {
          _myFriends = result;
          _allFriends = members;
          _filteredFriends = List.from(members);
          _loadingFriends = false;
        });

        _populateFilterOptions();
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loadingFriends = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _populateFilterOptions() {
    final categories = _allFriends
        .map((member) => member.categoryName)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    _availableCategories = ['Sve kategorije', ...categories];
  }

  void _applyFilters() {
    if (_allFriends.isEmpty) return;

    List<Member> filtered = List.from(_allFriends);

    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((member) {
        return member.firstName.toLowerCase().contains(searchTerm) ||
            member.lastName.toLowerCase().contains(searchTerm) ||
            member.username.toLowerCase().contains(searchTerm);
      }).toList();
    }

    if (_selectedCity != 'Svi gradovi') {
      final selectedCityId = _cities
          .firstWhere(
            (city) => city.name == _selectedCity,
            orElse: () => City(id: 0, name: '', createdAt: DateTime.now()),
          )
          .id;
      filtered = filtered
          .where((member) => member.cityId == selectedCityId)
          .toList();
    }

    if (_selectedTroop != 'Svi odredi') {
      final selectedTroopId = _troops
          .firstWhere(
            (troop) => troop.name == _selectedTroop,
            orElse: () => Troop(
              id: 0,
              name: '',
              createdAt: DateTime.now(),
              foundingDate: DateTime.now(),
            ),
          )
          .id;
      filtered = filtered
          .where((member) => member.troopId == selectedTroopId)
          .toList();
    }

    if (_selectedGender != 'Svi spolovi') {
      final genderValue = _selectedGender == 'Muški' ? 0 : 1;
      filtered = filtered
          .where((member) => member.gender == genderValue)
          .toList();
    }

    if (_selectedCategory != 'Sve kategorije') {
      filtered = filtered
          .where((member) => member.categoryName == _selectedCategory)
          .toList();
    }

    setState(() {
      _filteredFriends = filtered;
    });
  }

  Future<void> _loadPendingRequests() async {
    if (_loadingPending) return;

    setState(() {
      _loadingPending = true;
    });

    try {
      final result = await _friendshipProvider.getPendingRequests();

      if (mounted) {
        setState(() {
          _pendingRequests = result;
          _loadingPending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingPending = false;
        });
      }
    }
  }

  Future<void> _loadSentRequests() async {
    if (_loadingSent) return;

    setState(() {
      _loadingSent = true;
    });

    try {
      final result = await _friendshipProvider.getSentRequests();

      if (mounted) {
        setState(() {
          _sentRequests = result;
          _loadingSent = false;
          _sentRequestUserIds =
              result.items?.map((f) => f.responderId).toSet() ?? {};
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSent = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    if (_loadingRecommendations) return;

    setState(() {
      _loadingRecommendations = true;
    });

    try {
      final recommendations = await _friendshipProvider
          .getFriendRecommendations(topN: 5);

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _loadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRecommendations = false;
        });
        print('Error loading recommendations: $e');
      }
    }
  }

  Future<void> _acceptFriendRequest(Friendship friendship) async {
    final confirmed = await _showAcceptConfirmationDialog(friendship);
    if (!confirmed) return;

    try {
      final success = await _friendshipProvider.acceptFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je prihvaćen',
        );
        await _loadData();
      } else {
        SnackBarUtils.showErrorSnackBar('Greška pri prihvatanju zahtjeva');
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e');
    }
  }

  Future<void> _rejectFriendRequest(Friendship friendship) async {
    final confirmed = await _showRejectConfirmationDialog(friendship);
    if (!confirmed) return;

    try {
      final success = await _friendshipProvider.rejectFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je odbačen',
        );
        await _loadData();
      } else {
        SnackBarUtils.showErrorSnackBar('Greška pri odbacivanju zahtjeva');
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e');
    }
  }

  Future<void> _cancelFriendRequest(Friendship friendship) async {
    final confirmed = await _showCancelConfirmationDialog(friendship);
    if (!confirmed) return;

    try {
      final success = await _friendshipProvider.cancelFriendRequest(
        friendship.id,
      );
      if (success) {
        SnackBarUtils.showSuccessSnackBar(
          'Zahtjev za prijateljstvo je otkazan',
        );
        await _loadData();
      } else {
        SnackBarUtils.showErrorSnackBar('Greška pri otkazivanju zahtjeva');
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: MasterScreen(
        headerTitle: 'Prijatelji',
        showBackButton: true,
        body: Container(
          color: const Color(0xFFF5F5DC),
          child: Column(
            children: [
              _buildFilters(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
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
                    hintText: 'Pretraži prijatelje...',
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

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Moji prijatelji'),
                  Tab(text: 'Zahtjevi'),
                  Tab(text: 'Poslani zahtjevi'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyFriendsTab(),
                  _buildPendingRequestsTab(),
                  _buildSentRequestsTab(),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildFindFriendsButton(),
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Grad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'Svi gradovi',
                    child: Text('Svi gradovi'),
                  ),
                  ..._cities.map(
                    (city) => DropdownMenuItem(
                      value: city.name,
                      child: Text(city.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value ?? 'Svi gradovi';
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedTroop,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Odred',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'Svi odredi',
                    child: Text('Svi odredi'),
                  ),
                  ..._troops.map(
                    (troop) => DropdownMenuItem(
                      value: troop.name,
                      child: Text(troop.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTroop = value ?? 'Svi odredi';
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
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
                value: _selectedGender,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Spol',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Svi spolovi',
                    child: Text('Svi spolovi'),
                  ),
                  DropdownMenuItem(value: 'Muški', child: Text('Muški')),
                  DropdownMenuItem(value: 'Ženski', child: Text('Ženski')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? 'Svi spolovi';
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyFriendsTab() {
    if (_loadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Greška: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyFriends,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    final friends = _filteredFriends;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Moji prijatelji',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (friends.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            _searchController.text.isNotEmpty ||
                                    _selectedCity != 'Svi gradovi' ||
                                    _selectedTroop != 'Svi odredi' ||
                                    _selectedGender != 'Svi spolovi' ||
                                    _selectedCategory != 'Sve kategorije'
                                ? Icons.search_off
                                : Icons.people_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty ||
                                    _selectedCity != 'Svi gradovi' ||
                                    _selectedTroop != 'Svi odredi' ||
                                    _selectedGender != 'Svi spolovi' ||
                                    _selectedCategory != 'Sve kategorije'
                                ? 'Nema rezultata za odabrane filtere'
                                : 'Nemate prijatelja',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchController.text.isNotEmpty ||
                              _selectedCity != 'Svi gradovi' ||
                              _selectedTroop != 'Svi odredi' ||
                              _selectedGender != 'Svi spolovi' ||
                              _selectedCategory != 'Sve kategorije') ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCity = 'Svi gradovi';
                                  _selectedTroop = 'Svi odredi';
                                  _selectedGender = 'Svi spolovi';
                                  _selectedCategory = 'Sve kategorije';
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
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: friends.take(5).map((member) {
                        return _buildFriendItem(
                          name: '${member.firstName} ${member.lastName}',
                          profilePictureUrl: member.profilePictureUrl,
                          onTap: () => _showFriendOptionsForMember(member),
                        );
                      }).toList(),
                    ),
                  ),
                if (friends.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MemberListScreen(
                                title: 'Moji prijatelji',
                                showFriends: true,
                                filteredFriends: _filteredFriends,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Prikaži sve',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preporučeni prijatelji',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (_loadingRecommendations)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_recommendations.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nema preporučenih prijatelja',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _recommendations.map((recommendation) {
                        return _buildRecommendationItem(recommendation);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    if (_loadingPending) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = _pendingRequests?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zahtjevi za prijateljstvo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nemate novih zahtjeva',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestItem(
                    name: request.requesterFullName,
                    profilePictureUrl: request.requesterProfilePictureUrl,
                    memberId: request.requesterId,
                    onAccept: () => _acceptFriendRequest(request),
                    onReject: () => _rejectFriendRequest(request),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSentRequestsTab() {
    if (_loadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = _sentRequests?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poslani zahtjevi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Niste poslali nijedan zahtjev',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildSentRequestItem(
                    name: request.responderFullName,
                    profilePictureUrl: request.responderProfilePictureUrl,
                    memberId: request.responderId,
                    onCancel: () => _cancelFriendRequest(request),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFindFriendsButton() {
    return Align(
      alignment: Alignment.center,
      child: FloatingActionButton.extended(
        onPressed: _navigateToFindFriends,
        icon: const Icon(Icons.person_add, size: 20),
        label: const Text(
          'Pronađi prijatelje',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Future<void> _navigateToFindFriends() async {
    try {
      final result = await _memberProvider.getAvailableMembers(
        filter: {"RetrieveAll": true},
      );
      final availableMembers = result.items ?? [];

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemberListScreen(
              title: 'Pronađi prijatelje',
              filteredFriends: availableMembers,
              showFriends: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri učitavanju članova: $e',
          context: context,
        );
      }
    }
  }

  Widget _buildFriendItem({
    required String name,
    required String profilePictureUrl,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: profilePictureUrl.isNotEmpty
            ? NetworkImage(UrlUtils.buildImageUrl(profilePictureUrl))
            : null,
        child: profilePictureUrl.isEmpty
            ? const Icon(Icons.person, size: 30)
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRecommendationItem(FriendRecommendation recommendation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: recommendation.profilePictureUrl.isNotEmpty
            ? NetworkImage(
                UrlUtils.buildImageUrl(recommendation.profilePictureUrl),
              )
            : null,
        child: recommendation.profilePictureUrl.isEmpty
            ? const Icon(Icons.person, size: 30)
            : null,
      ),
      title: Text(
        recommendation.fullName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: null,
      trailing: _sentRequestUserIds.contains(recommendation.userId)
          ? IconButton(
              icon: const Icon(
                Icons.hourglass_empty,
                color: Colors.orange,
                size: 20,
              ),
              onPressed: null,
              tooltip: 'Zahtjev poslan',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            )
          : IconButton(
              icon: const Icon(Icons.person_add, color: Colors.green, size: 20),
              onPressed: () =>
                  _sendFriendRequestToRecommendation(recommendation),
              tooltip: 'Pošalji zahtjev za prijateljstvo',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
      onTap: () => _showRecommendationProfile(recommendation),
    );
  }

  Widget _buildRequestItem({
    required String name,
    required String profilePictureUrl,
    required int memberId,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: profilePictureUrl.isNotEmpty
              ? NetworkImage(UrlUtils.buildImageUrl(profilePictureUrl))
              : null,
          child: profilePictureUrl.isEmpty
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Želi da bude Vaš prijatelj'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onAccept,
              tooltip: 'Prihvati',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onReject,
              tooltip: 'Odbaci',
            ),
          ],
        ),
        onTap: () => _navigateToProfile(memberId),
      ),
    );
  }

  Widget _buildSentRequestItem({
    required String name,
    required String profilePictureUrl,
    required int memberId,
    required VoidCallback onCancel,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: profilePictureUrl.isNotEmpty
              ? NetworkImage(UrlUtils.buildImageUrl(profilePictureUrl))
              : null,
          child: profilePictureUrl.isEmpty
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Čekanje odgovora'),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.orange),
          onPressed: onCancel,
          tooltip: 'Otkaži zahtjev',
        ),
        onTap: () => _navigateToProfile(memberId),
      ),
    );
  }

  Future<bool> _showAcceptConfirmationDialog(Friendship friendship) async {
    final friendName = friendship.requesterFullName;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Prihvati zahtjev za prijateljstvo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Da li ste sigurni da želite prihvatiti zahtjev za prijateljstvo od $friendName?',
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

  Future<bool> _showRejectConfirmationDialog(Friendship friendship) async {
    final friendName = friendship.requesterFullName;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Odbij zahtjev za prijateljstvo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Da li ste sigurni da želite odbiti zahtjev za prijateljstvo od $friendName?',
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

  Future<bool> _showCancelConfirmationDialog(Friendship friendship) async {
    final friendName = friendship.responderFullName;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Otkaži zahtjev za prijateljstvo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Da li ste sigurni da želite otkazati zahtjev za prijateljstvo za $friendName?',
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

  void _showFriendOptionsForMember(Member member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Ukloni prijatelja'),
              onTap: () {
                Navigator.pop(context);
                _showUnfriendDialogForMember(member);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnfriendDialogForMember(Member member) {
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
                  onPressed: () {
                    Navigator.pop(context);
                    _unfriendByMemberId(member.id);
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

  Future<void> _unfriendByMemberId(int memberId) async {
    try {
      final friendships = _myFriends?.items ?? [];
      Friendship? friendshipToRemove;

      for (final friendship in friendships) {
        if ((friendship.requesterId == _currentUserId &&
                friendship.responderId == memberId) ||
            (friendship.requesterId == memberId &&
                friendship.responderId == _currentUserId)) {
          friendshipToRemove = friendship;
          break;
        }
      }

      if (friendshipToRemove != null) {
        final success = await _friendshipProvider.unfriend(
          friendshipToRemove.id,
        );
        if (success) {
          SnackBarUtils.showSuccessSnackBar('Prijatelj je uklonjen');
          await _loadData();
        } else {
          SnackBarUtils.showErrorSnackBar('Greška pri uklanjanju prijatelja');
        }
      } else {
        SnackBarUtils.showErrorSnackBar('Prijateljstvo nije pronađeno');
      }
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e');
    }
  }

  Future<void> _sendFriendRequestToRecommendation(
    FriendRecommendation recommendation,
  ) async {
    final confirmed = await _showSendRequestConfirmationDialog(recommendation);
    if (!confirmed) return;

    try {
      await _friendshipProvider.sendFriendRequest(recommendation.userId);
      SnackBarUtils.showSuccessSnackBar(
        'Zahtjev za prijateljstvo je poslan izviđaču ${recommendation.fullName}',
      );

      setState(() {
        _sentRequestUserIds.add(recommendation.userId);
      });

      await _loadSentRequests();
    } catch (e) {
      SnackBarUtils.showErrorSnackBar('Greška: $e');
    }
  }

  Future<bool> _showSendRequestConfirmationDialog(
    FriendRecommendation recommendation,
  ) async {
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
                'Da li ste sigurni da želite poslati zahtjev za prijateljstvo ${recommendation.fullName}?',
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

  void _showRecommendationProfile(FriendRecommendation recommendation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(memberId: recommendation.userId),
      ),
    );
  }

  void _navigateToProfile(int memberId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(memberId: memberId),
      ),
    );
  }
}
