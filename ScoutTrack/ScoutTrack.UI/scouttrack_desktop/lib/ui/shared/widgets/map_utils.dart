import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  /// Shows a map picker dialog for location selection
  static Future<LatLng?> showMapPickerDialog({
    required BuildContext context,
    required LatLng initialLocation,
    String title = 'Odaberite lokaciju',
    double initialZoom = 10.0,
  }) async {
    final MapController mapController = MapController();
    LatLng selectedLocation = initialLocation;

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: initialLocation,
              zoom: initialZoom,
              onTap: (tapPosition, point) {
                Navigator.of(context).pop({
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                });
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
                    point: selectedLocation,
                    width: 40,
                    height: 40,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Otkaži'),
          ),
        ],
      ),
    );

    if (result != null) {
      return LatLng(result['latitude']!, result['longitude']!);
    }
    return null;
  }

  /// Creates a map widget with a marker at the specified location
  static Widget createMapWidget({
    required LatLng location,
    required MapController mapController,
    double zoom = 13.0,
    double height = 300,
    bool showMarker = true,
  }) {
    return SizedBox(
      height: height,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(center: location, zoom: zoom),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.scouttrack_desktop',
          ),
          if (showMarker)
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
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
    );
  }

  /// Creates an interactive map widget for location selection
  static Widget createInteractiveMapWidget({
    required LatLng location,
    required MapController mapController,
    required Function(LatLng) onLocationChanged,
    double zoom = 10.0,
    double height = 300,
  }) {
    return SizedBox(
      height: height,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: location,
          zoom: zoom,
          onTap: (tapPosition, point) {
            onLocationChanged(point);
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
                point: location,
                width: 40,
                height: 40,
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
    );
  }

  /// Formats coordinates for display
  static String formatCoordinates(LatLng location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  /// Validates if coordinates are within reasonable bounds
  static bool isValidCoordinates(LatLng location) {
    return location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }
}
