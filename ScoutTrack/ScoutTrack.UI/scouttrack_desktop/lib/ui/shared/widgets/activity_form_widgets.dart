import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/map_utils.dart';

class ActivityFormWidgets {
  static Widget buildEquipmentItem({
    required int index,
    required String item,
    required Equipment? equipment,
    required TextEditingController controller,
    required Function(StateSetter, int, String) onUpdate,
    required Function(StateSetter, int) onRemove,
    required StateSetter setState,
    bool isNewlyAdded = false, // Add parameter for highlighting
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: isNewlyAdded
            ? BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: isNewlyAdded ? const EdgeInsets.all(8) : EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Unesite naziv opreme',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      prefixIcon: Icon(
                        equipment != null ? Icons.inventory_2 : Icons.add,
                        color: equipment != null ? Colors.blue : Colors.green,
                        size: 16,
                      ),
                    ),
                    onChanged: (value) => onUpdate(setState, index, value),
                  ),
                  if (equipment?.description.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        equipment!.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onRemove(setState, index),
              icon: const Icon(Icons.close, color: Colors.red),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLocationPicker({
    required LatLng? selectedLocation,
    required Function(StateSetter) onLocationSelect,
    required StateSetter setState,
  }) {
    return GestureDetector(
      onTap: () => onLocationSelect(setState),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Odaberite lokaciju održavanja',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    MapUtils.formatCoordinates(
                      selectedLocation ?? const LatLng(0, 0),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static Widget buildDateTimeRow({
    required String label,
    required String dateValue,
    required String timeValue,
    required Function(StateSetter) onDateSelect,
    required Function(StateSetter) onTimeSelect,
    required StateSetter setState,
  }) {
    return Row(
      children: [
        Expanded(
          child: UIComponents.buildFormField(
            controller: TextEditingController(text: dateValue),
            labelText: '$label datum',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label datum je obavezan';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: UIComponents.buildFormField(
            controller: TextEditingController(text: timeValue),
            labelText: '$label vrijeme',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label vrijeme je obavezno';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => onDateSelect(setState),
          icon: const Icon(Icons.calendar_today),
        ),
        IconButton(
          onPressed: () => onTimeSelect(setState),
          icon: const Icon(Icons.access_time),
        ),
      ],
    );
  }

  static Widget buildImagePicker({
    required Uint8List? selectedImageBytes,
    required String? imagePath,
    required Function(StateSetter) onImagePick,
    required StateSetter setState,
  }) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: selectedImageBytes != null
                ? Image.memory(selectedImageBytes, fit: BoxFit.cover)
                : (imagePath != null && imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                ),
                          ),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => onImagePick(setState),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
