import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerDialog({super.key, required this.initialLocation});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _selectedLocation;
  String _city = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _getCityFromLatLng(_selectedLocation);
  }

  Future<void> _getCityFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final place = placemarks.first;
      if (mounted) {
        setState(() {
          _city =
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _city = '');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: _selectedLocation,
                  zoom: 13.0,
                  onTap: (_, latLng) {
                    setState(() {
                      _selectedLocation = latLng;
                    });
                    _getCityFromLatLng(latLng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.scouttrack_desktop',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _loading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Odabrani grad: ${_city.isNotEmpty ? _city : 'Nepoznato'}',
                        ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'latitude': _selectedLocation.latitude,
                        'longitude': _selectedLocation.longitude,
                        'city': _city,
                      });
                    },
                    child: const Text('Potvrdi lokaciju'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
