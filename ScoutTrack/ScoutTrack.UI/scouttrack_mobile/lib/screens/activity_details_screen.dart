import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../models/activity.dart';
import '../models/activity_equipment.dart';
import '../models/troop.dart';
import '../utils/url_utils.dart';
import '../providers/troop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_equipment_provider.dart';
import 'troop_details_screen.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MapController _mapController;
  LatLng? _activityLocation;
  List<ActivityEquipment> _equipment = [];
  bool _isLoadingEquipment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mapController = MapController();

    if (widget.activity.latitude != 0 && widget.activity.longitude != 0) {
      _activityLocation = LatLng(
        widget.activity.latitude,
        widget.activity.longitude,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_activityLocation != null) {
          _mapController.move(_activityLocation!, 15.0);
        }
      });
    }
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _isLoadingEquipment = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final equipmentProvider = ActivityEquipmentProvider(authProvider);
      final equipment = await equipmentProvider.getByActivityId(
        widget.activity.id,
      );

      if (mounted) {
        setState(() {
          _equipment = equipment;
          _isLoadingEquipment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEquipment = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: widget.activity.title,
      selectedIndex: -1,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: Column(
          children: [
            _buildTabBar(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildGalleryTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Detalji'),
              Tab(text: 'Galerija'),
              Tab(text: 'Recenzije'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),

          _buildQuickInfoCards(),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),

                  _buildKeyInfoGrid(),
                  const SizedBox(height: 24),

                  if (widget.activity.activityState !=
                      'FinishedActivityState') ...[
                    _buildEquipmentSection(),
                    const SizedBox(height: 24),
                  ],

                  if (widget.activity.summary.isNotEmpty &&
                      widget.activity.activityState == 'FinishedActivityState')
                    _buildSummarySection(),
                ],
              ),
            ),
          ),

          if (_activityLocation != null) ...[
            const SizedBox(height: 16),
            _buildMapSection(),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    Widget contentWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[600])!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.grey[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showArrow)
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: contentWidget);
    }

    return contentWidget;
  }

  Widget _buildDateTimeInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple[600]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Colors.purple[600],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datum i vrijeme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.activity.startTime != null) ...[
                Row(
                  children: [
                    Icon(Icons.play_arrow, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Početak: ${_formatDateTime(widget.activity.startTime!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.activity.endTime != null) const SizedBox(height: 8),
              ],
              if (widget.activity.endTime != null)
                Row(
                  children: [
                    Icon(Icons.stop, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Kraj: ${_formatDateTime(widget.activity.endTime!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryTab() {
    return Container(
      color: const Color(0xFFF5F5DC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.photo_library,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Galerija',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Fotografije aktivnosti će biti dostupne ovdje',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Container(
      color: const Color(0xFFF5F5DC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.star_rate, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'Recenzije',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Recenzije i ocjene aktivnosti će biti dostupne ovdje',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.activity.imagePath.isNotEmpty
                ? Image.network(
                    UrlUtils.buildImageUrl(widget.activity.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      transform: Matrix4.translationValues(0, -40, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.play_arrow,
              title: 'Početak',
              value: widget.activity.startTime != null
                  ? '${DateFormat('dd.MM.yyyy').format(widget.activity.startTime!)}\n${DateFormat('HH:mm').format(widget.activity.startTime!)}'
                  : 'N/A',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.stop,
              title: 'Kraj',
              value: widget.activity.endTime != null
                  ? '${DateFormat('dd.MM.yyyy').format(widget.activity.endTime!)}\n${DateFormat('HH:mm').format(widget.activity.endTime!)}'
                  : 'N/A',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _buildQuickInfoCard(
              icon: Icons.payments,
              title: 'Kotizacija',
              value: widget.activity.fee > 0
                  ? '${widget.activity.fee.toStringAsFixed(0)} KM'
                  : 'Besplatno',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.activity.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.group, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: _navigateToTroopDetails,
                child: Text(
                  'Odred izviđača "${widget.activity.troopName}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 12),

        _buildActivityStateBadge(),
      ],
    );
  }

  Widget _buildKeyInfoGrid() {
    return Column(
      children: [
        if (widget.activity.description.isNotEmpty) ...[
          _buildDescriptionSection(),
          const SizedBox(height: 24),
        ],

        _buildInfoCard(
          icon: Icons.category,
          title: 'Tip aktivnosti',
          content: widget.activity.activityTypeName,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),

        _buildInfoCard(
          icon: Icons.location_on,
          title: 'Lokacija',
          content: widget.activity.locationName,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),

        _buildRegistrationStatusCard(),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info, color: Colors.amber[700], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Rezime',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Text(
            widget.activity.summary,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description, color: Colors.teal[700], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Opis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.2)),
          ),
          child: Text(
            widget.activity.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.map, color: Colors.red[600], size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lokacija na mapi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _activityLocation!,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.flingAnimation,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.scouttrack_mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _activityLocation!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nema slike',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToTroopDetails() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final troopProvider = TroopProvider(authProvider);

      Troop? troop;

      if (widget.activity.troopId > 0) {
        troop = await troopProvider.getById(widget.activity.troopId);
      } else {
        final troopResult = await troopProvider.get(
          filter: {"RetrieveAll": true},
        );

        if (troopResult.items != null && troopResult.items!.isNotEmpty) {
          try {
            troop = troopResult.items!.firstWhere(
              (t) => t.name == widget.activity.troopName,
            );
          } catch (e) {
            troop = troopResult.items!.firstWhere(
              (t) =>
                  t.name.toLowerCase().contains(
                    widget.activity.troopName.toLowerCase(),
                  ) ||
                  widget.activity.troopName.toLowerCase().contains(
                    t.name.toLowerCase(),
                  ),
              orElse: () => throw Exception(
                'Troop "${widget.activity.troopName}" not found',
              ),
            );
          }
        } else {
          throw Exception('No troops available');
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TroopDetailsScreen(troop: troop!),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri učitavanju odreda: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.build, color: Colors.purple[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Preporučena oprema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingEquipment)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_equipment.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nema preporučene opreme za ovu aktivnost',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._equipment.map((equipment) => _buildEquipmentItem(equipment)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEquipmentItem(ActivityEquipment equipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.purple[600],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.equipmentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (equipment.equipmentDescription.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    equipment.equipmentDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  Widget _buildActivityStateBadge() {
    String stateText;
    Color stateColor;
    IconData stateIcon;

    switch (widget.activity.activityState) {
      case 'RegistrationsOpenActivityState':
        stateText = 'Prijave otvorene';
        stateColor = Colors.green;
        stateIcon = Icons.lock_open;
        break;
      case 'RegistrationsClosedActivityState':
        stateText = 'Prijave zatvorene';
        stateColor = Colors.orange;
        stateIcon = Icons.lock;
        break;
      case 'FinishedActivityState':
        stateText = 'Završena';
        stateColor = Colors.blue;
        stateIcon = Icons.check_circle;
        break;
      default:
        stateText = 'Nepoznato stanje';
        stateColor = Colors.grey;
        stateIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stateColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stateIcon, size: 16, color: stateColor),
          const SizedBox(width: 6),
          Text(
            stateText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: stateColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationStatusCard() {
    if (widget.activity.activityState == 'FinishedActivityState') {
      return _buildInfoCard(
        icon: Icons.people,
        title: 'Broj prisutnih',
        content: '${widget.activity.registrationCount} prisutnih',
        color: Colors.green,
      );
    }

    if (widget.activity.activityState == 'RegistrationsOpenActivityState' ||
        widget.activity.activityState == 'RegistrationsClosedActivityState') {
      return Column(
        children: [
          _buildInfoCard(
            icon: Icons.pending_actions,
            title: 'Prijave na čekanju',
            content: '${widget.activity.pendingRegistrationCount} prijava',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.check_circle,
            title: 'Odobrene prijave',
            content: '${widget.activity.approvedRegistrationCount} prijava',
            color: Colors.blue,
          ),
        ],
      );
    }

    return _buildInfoCard(
      icon: Icons.people,
      title: 'Broj prijava',
      content: '${widget.activity.registrationCount} prijava',
      color: Colors.purple,
    );
  }
}
