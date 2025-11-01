import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/troop.dart';
import '../layouts/master_screen.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'activity_list_screen.dart';
import 'member_list_screen.dart';

class TroopDetailsScreen extends StatefulWidget {
  final Troop troop;
  final bool alwaysShowMenu;

  const TroopDetailsScreen({
    super.key,
    required this.troop,
    this.alwaysShowMenu = false,
  });

  @override
  State<TroopDetailsScreen> createState() => _TroopDetailsScreenState();
}

class _TroopDetailsScreenState extends State<TroopDetailsScreen> {
  late Troop _troop;
  late MapController _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _troop = widget.troop;
    _mapController = MapController();

    if (_troop.latitude != 0 && _troop.longitude != 0) {
      _selectedLocation = LatLng(_troop.latitude, _troop.longitude);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_selectedLocation!, 15.0);
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  void _navigateToMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberListScreen(
          troopId: _troop.id,
          title: 'Članovi odreda "${_troop.name}"',
        ),
      ),
    );
  }

  void _navigateToEvents() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityListScreen(
          troopId: _troop.id,
          title: 'Aktivnosti odreda "${_troop.name}"',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = _troop.latitude != 0 && _troop.longitude != 0;

    return MasterScreen(
      headerTitle: 'Odred izviđača "${_troop.name}"',
      selectedIndex: -1,
      alwaysShowMenu: widget.alwaysShowMenu,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _troop.logoUrl.isNotEmpty
                          ? NetworkImage(
                              UrlUtils.buildImageUrl(_troop.logoUrl),
                              headers: const {
                                'User-Agent': 'ScoutTrack Mobile App',
                              },
                            )
                          : null,
                      child: _troop.logoUrl.isEmpty
                          ? Icon(
                              Icons.group,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      _troop.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    _buildTroopInfoCard(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildNavigationCard(
                      'Članovi',
                      Icons.people,
                      const Color(0xFF2196F3),
                      _navigateToMembers,
                    ),
                    const SizedBox(height: 16),

                    _buildNavigationCard(
                      'Aktivnosti',
                      Icons.event,
                      const Color(0xFF4CAF50),
                      _navigateToEvents,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              if (hasCoordinates) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: Container(
                      height: 250,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation!,
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.scouttrack.mobile',
                            maxZoom: 18,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 200,
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
                          'Nema dostupnih koordinata',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroopInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.location_on,
            'Lokacija',
            _troop.cityName.isNotEmpty ? _troop.cityName : 'Nije specificirano',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.supervisor_account,
            'Starješina',
            _troop.scoutMaster.isNotEmpty
                ? _troop.scoutMaster
                : 'Nije specificirano',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.leaderboard,
            'Načelnik',
            _troop.troopLeader.isNotEmpty
                ? _troop.troopLeader
                : 'Nije specificirano',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.email,
            'Email',
            _troop.email.isNotEmpty ? _troop.email : 'Nije specificirano',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone,
            'Telefon',
            _troop.contactPhone.isNotEmpty
                ? _troop.contactPhone
                : 'Nije specificirano',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Datum osnivanja',
            _formatDate(_troop.foundingDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.people, 'Broj članova', '${_troop.memberCount}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Nije uneseno',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
