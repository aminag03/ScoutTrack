import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/troop.dart';
import '../providers/troop_provider.dart';
import '../providers/auth_provider.dart';
import '../layouts/master_screen.dart';
import '../utils/snackbar_utils.dart';
import 'troop_details_screen.dart';

class TroopMapScreen extends StatefulWidget {
  const TroopMapScreen({super.key});

  @override
  State<TroopMapScreen> createState() => _TroopMapScreenState();
}

class _TroopMapScreenState extends State<TroopMapScreen> {
  late MapController _mapController;
  List<Troop> _troops = [];
  List<Troop> _filteredTroops = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = '';
  List<String> _availableCities = [];

  Map<String, List<Troop>> _locationClusters = {};
  static const double _clusterRadius = 0.001; // ~100m radius for clustering

  bool _showTroopListCard = false;
  List<Troop> _selectedClusterTroops = [];

  static const LatLng _defaultCenter = LatLng(43.9159, 17.6791);
  static const double _defaultZoom = 7.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadTroops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTroops() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final troopProvider = TroopProvider(authProvider);

      final troops = await troopProvider.getAll();

      final troopsWithCoordinates = troops
          .where((troop) => troop.latitude != 0 && troop.longitude != 0)
          .toList();

      final cities =
          troopsWithCoordinates
              .map((troop) => troop.cityName)
              .where((city) => city.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      setState(() {
        _troops = troopsWithCoordinates;
        _filteredTroops = troopsWithCoordinates;
        _availableCities = cities;
        _isLoading = false;
      });

      _clusterTroopsByLocation();

      if (_filteredTroops.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(
              _filteredTroops.first.latitude,
              _filteredTroops.first.longitude,
            ),
            _defaultZoom,
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri učitavanju odreda: ${e.toString()}',
        );
      }
    }
  }

  void _filterTroops(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Troop> filtered = List.from(_troops);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (troop) =>
                troop.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_selectedCity.isNotEmpty) {
      filtered = filtered
          .where((troop) => troop.cityName == _selectedCity)
          .toList();
    }

    setState(() {
      _filteredTroops = filtered;
      _clusterTroopsByLocation();
    });
  }

  void _clusterTroopsByLocation() {
    _locationClusters.clear();
    List<Troop> unclusteredTroops = List.from(_filteredTroops);
    int clusterId = 0;

    while (unclusteredTroops.isNotEmpty) {
      Troop seedTroop = unclusteredTroops.removeAt(0);
      String clusterKey = 'cluster_$clusterId';
      List<Troop> cluster = [seedTroop];

      for (int i = unclusteredTroops.length - 1; i >= 0; i--) {
        Troop otherTroop = unclusteredTroops[i];
        double distance = _calculateDistance(
          LatLng(seedTroop.latitude, seedTroop.longitude),
          LatLng(otherTroop.latitude, otherTroop.longitude),
        );

        if (distance <= _clusterRadius) {
          cluster.add(otherTroop);
          unclusteredTroops.removeAt(i);
        }
      }

      _locationClusters[clusterKey] = cluster;
      clusterId++;
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  void _showTroopListPopup(
    String clusterKey,
    List<Troop> troops,
    LatLng position,
  ) {
    setState(() {
      _showTroopListCard = true;
      _selectedClusterTroops = troops;
    });
  }

  void _hideTroopListPopup() {
    setState(() {
      _showTroopListCard = false;
      _selectedClusterTroops = [];
    });
  }

  void _setCityFilter(String city) {
    setState(() {
      _selectedCity = city;
    });
    _applyFilters();
  }

  void _clearCityFilter() {
    setState(() {
      _selectedCity = '';
    });
    _applyFilters();
  }

  void _navigateToTroopDetails(Troop troop) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TroopDetailsScreen(troop: troop)),
    );
  }

  List<Marker> _buildClusteredMarkers() {
    List<Marker> markers = [];

    for (String locationKey in _locationClusters.keys) {
      List<Troop> troopsAtLocation = _locationClusters[locationKey]!;

      if (troopsAtLocation.length == 1) {
        Troop troop = troopsAtLocation.first;
        markers.add(_buildSingleTroopMarker(troop));
      } else {
        markers.add(_buildClusterMarker(locationKey, troopsAtLocation));
      }
    }

    return markers;
  }

  Marker _buildSingleTroopMarker(Troop troop) {
    return Marker(
      point: LatLng(troop.latitude, troop.longitude),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _navigateToTroopDetails(troop),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Marker _buildClusterMarker(String clusterKey, List<Troop> troops) {
    double centerLat =
        troops.map((t) => t.latitude).reduce((a, b) => a + b) / troops.length;
    double centerLng =
        troops.map((t) => t.longitude).reduce((a, b) => a + b) / troops.length;

    return Marker(
      point: LatLng(centerLat, centerLng),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showTroopListPopup(
          clusterKey,
          troops,
          LatLng(centerLat, centerLng),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${troops.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.group, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroopListCard() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Odredi (${_selectedClusterTroops.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _hideTroopListPopup,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedClusterTroops.length,
                itemBuilder: (context, index) {
                  final troop = _selectedClusterTroops[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      troop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      troop.cityName.isNotEmpty
                          ? troop.cityName
                          : 'Nepoznata lokacija',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _hideTroopListPopup();
                      _navigateToTroopDetails(troop);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isActive,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCityFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Odaberi grad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Svi gradovi'),
              onTap: () {
                _clearCityFilter();
                Navigator.pop(context);
              },
              trailing: _selectedCity.isEmpty ? const Icon(Icons.check) : null,
            ),
            ..._availableCities.map(
              (city) => ListTile(
                title: Text(city),
                onTap: () {
                  _setCityFilter(city);
                  Navigator.pop(context);
                },
                trailing: _selectedCity == city
                    ? const Icon(Icons.check)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Mapa odreda',
      selectedIndex: -1,
      alwaysShowMenu: true,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterTroops,
                      decoration: const InputDecoration(
                        hintText: 'Pretraži po nazivu...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_availableCities.isNotEmpty) ...[
                          _buildFilterChip(
                            label: 'Grad',
                            value: _selectedCity.isEmpty
                                ? 'Svi gradovi'
                                : _selectedCity,
                            onTap: _showCityFilter,
                            isActive: _selectedCity.isNotEmpty,
                            onClear: _selectedCity.isNotEmpty
                                ? _clearCityFilter
                                : null,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ukupno pronađeno odreda: ${_filteredTroops.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedCity.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'U gradu: $_selectedCity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Stack(
                children: [
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTroops.isEmpty
                      ? _buildEmptyState()
                      : _buildMap(),

                  if (_showTroopListCard) _buildTroopListCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nema odreda za prikaz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: _defaultZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.scouttrack.mobile',
              maxZoom: 18,
            ),

            MarkerLayer(markers: _buildClusteredMarkers()),
          ],
        ),
      ),
    );
  }
}
