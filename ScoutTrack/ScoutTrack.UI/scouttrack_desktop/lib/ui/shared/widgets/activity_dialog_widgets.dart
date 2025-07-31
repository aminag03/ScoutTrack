import 'package:flutter/material.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/models/activity_equipment.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/form_validation_utils.dart';

class ActivityDialogWidgets {
  static Future<dynamic> showEquipmentSelectionDialog({
    required BuildContext context,
    required List<Equipment> equipment,
    required Function() onAddNewEquipment,
  }) async {
    return await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Odaberite opremu'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: Column(
              children: [
                const Text(
                  'Odaberite postojeću opremu ili dodajte novu:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: equipment.length + 1, // +1 for "Add new" option
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: const Icon(Icons.add, color: Colors.green),
                          title: const Text('Dodaj novu opremu'),
                          subtitle: const Text('Kreirajte novu stavku opreme'),
                          onTap: () async {
                            Navigator.of(context).pop();
                            final newEquipment = await onAddNewEquipment();
                            if (newEquipment != null) {
                              Navigator.of(context).pop(newEquipment);
                            }
                          },
                        );
                      } else {
                        final equipmentItem = equipment[index - 1];
                        return ListTile(
                          leading: const Icon(
                            Icons.inventory_2,
                            color: Colors.blue,
                          ),
                          title: Text(equipmentItem.name),
                          subtitle: Text(
                            equipmentItem.description.isNotEmpty
                                ? equipmentItem.description
                                : 'Nema opisa',
                          ),
                          onTap: () => Navigator.of(context).pop(equipmentItem),
                        );
                      }
                    },
                  ),
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
        );
      },
    );
  }

  static Future<Equipment?> showAddNewEquipmentDialog({
    required BuildContext context,
    required Function(Equipment) onEquipmentAdded,
  }) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<Equipment>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj novu opremu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UIComponents.buildFormField(
                  controller: nameController,
                  labelText: 'Naziv opreme *',
                  validator: (value) => FormValidationUtils.validateRequired(
                    value,
                    'Naziv opreme',
                  ),
                ),
                const SizedBox(height: 16),
                UIComponents.buildFormField(
                  controller: descriptionController,
                  labelText: 'Opis (opciono)',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final newEquipment = await onEquipmentAdded(
                      Equipment(
                        id: 0,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        isGlobal: false,
                        createdAt: DateTime.now(),
                      ),
                    );
                    Navigator.of(context).pop(newEquipment);
                  } catch (e) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showActivityEquipmentDialog({
    required BuildContext context,
    required String activityName,
    required List<ActivityEquipment> equipment,
  }) async {
    return await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Oprema za aktivnost: $activityName'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: equipment.isEmpty
                ? const Center(
                    child: Text(
                      'Nema dodane opreme za ovu aktivnost.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: equipment.length,
                    itemBuilder: (context, index) {
                      final item = equipment[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.inventory_2,
                          color: Colors.blue,
                        ),
                        title: Text(item.equipmentName),
                        subtitle: item.equipmentDescription.isNotEmpty
                            ? Text(item.equipmentDescription)
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }
}
