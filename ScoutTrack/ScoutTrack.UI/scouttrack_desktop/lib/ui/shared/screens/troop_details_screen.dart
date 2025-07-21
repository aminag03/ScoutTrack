import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';

class TroopDetailsScreen extends StatefulWidget {
  final Troop troop;

  const TroopDetailsScreen({super.key, required this.troop});

  @override
  State<TroopDetailsScreen> createState() => _TroopDetailsScreenState();
}

class _TroopDetailsScreenState extends State<TroopDetailsScreen> {
  late Troop _troop;
  bool _isLoading = false;
  late MapController _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _troop = widget.troop;
    _mapController = MapController();
    if (_troop.latitude != null && _troop.longitude != null) {
      _selectedLocation = LatLng(_troop.latitude!, _troop.longitude!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, 13.0);
      }
    });
  }

  Future<void> _toggleActivation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_troop.isActive ? 'Deaktivacija' : 'Aktivacija'),
        content: Text(
          _troop.isActive
              ? 'Da li ste sigurni da želite deaktivirati ovaj odred?'
              : 'Da li ste sigurni da želite aktivirati ovaj odred?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final troopProvider = Provider.of<TroopProvider>(context, listen: false);
      final updatedTroop = await troopProvider.activate(_troop.id);

      setState(() {
        _troop = updatedTroop;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _troop.isActive
                  ? 'Odred je uspješno aktiviran.'
                  : 'Odred je uspješno deaktiviran.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _troop.logoUrl.isNotEmpty ? _troop.logoUrl : null;
    final hasCoordinates = _troop.latitude != null && _troop.longitude != null;

    return MasterScreen(
      selectedMenu: null,
      role: 'Admin',
      title: _troop.name,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/scouttrack_logo.png') as ImageProvider,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _troop.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _troop.cityName, 
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildDetailRow('Korisničko ime', _troop.username),
            _buildDetailRow('E-mail', _troop.email),
            _buildDetailRow('Grad', _troop.cityName),
            _buildDetailRow('Broj članova', _troop.memberCount.toString()),
            _buildDetailRow('Kontakt telefon', _troop.contactPhone),
            _buildDetailRow('Aktivan', _troop.isActive ? 'Da' : 'Ne'),
            _buildDetailRow('Kreiran', formatDateTime(_troop.createdAt)),
            _buildDetailRow('Zadnja prijava', _troop.lastLoginAt != null ? formatDateTime(_troop.lastLoginAt!) : '-'),
            
            const SizedBox(height: 24),
            const Text('Lokacija:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: 300,
              child: Card(
                elevation: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasCoordinates
                      ? FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: _selectedLocation,
                            zoom: 13.0,
                            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            onTap: (tapPosition, point) {
                              // Disable tap-to-change location in details view
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.scouttrack_desktop',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Center(
                          child: Text('Nema dostupnih koordinata'),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: Icon(_troop.isActive ? Icons.block : Icons.check_circle),
                label: Text(_troop.isActive ? 'Deaktiviraj odred' : 'Aktiviraj odred'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _troop.isActive ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _isLoading ? null : _toggleActivation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}