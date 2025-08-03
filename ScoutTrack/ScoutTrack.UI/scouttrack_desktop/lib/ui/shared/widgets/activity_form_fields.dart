import 'package:flutter/material.dart';
import 'package:scouttrack_desktop/models/activity_type.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';

class ActivityFormFields {
  static List<Widget> buildMainFormFields({
    required TextEditingController titleController,
    required TextEditingController locationNameController,
    required TextEditingController descriptionController,
    required TextEditingController feeController,
    required TextEditingController startDateController,
    required TextEditingController startTimeController,
    required TextEditingController endDateController,
    required TextEditingController endTimeController,
    required Function(StateSetter) onStartDateSelect,
    required Function(StateSetter) onStartTimeSelect,
    required Function(StateSetter) onEndDateSelect,
    required Function(StateSetter) onEndTimeSelect,
    required StateSetter setState,
  }) {
    return [
      UIComponents.buildFormField(
        controller: titleController,
        labelText: 'Upišite naziv aktivnosti',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Naziv je obavezan';
          }
          if (value.length > 100) {
            return 'Naziv ne smije biti duži od 100 znakova';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      UIComponents.buildFormField(
        controller: locationNameController,
        labelText: 'Upišite naziv lokacije',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Naziv lokacije je obavezan';
          }
          if (value.length > 200) {
            return 'Naziv lokacije ne smije biti duži od 200 znakova';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      UIComponents.buildFormField(
        controller: descriptionController,
        labelText: 'Opis aktivnosti',
        validator: (value) {
          if (value != null && value.length > 500) {
            return 'Opis ne smije biti duži od 500 znakova';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      UIComponents.buildFormField(
        controller: feeController,
        labelText: 'Kotizacija',
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final fee = double.tryParse(value);
            if (fee == null || fee < 0) {
              return 'Naknada mora biti pozitivan broj';
            }
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildDateTimeRow(
        label: 'Početak',
        dateController: startDateController,
        timeController: startTimeController,
        onDateSelect: onStartDateSelect,
        onTimeSelect: onStartTimeSelect,
        setState: setState,
      ),
      const SizedBox(height: 16),
      _buildDateTimeRow(
        label: 'Kraj',
        dateController: endDateController,
        timeController: endTimeController,
        onDateSelect: onEndDateSelect,
        onTimeSelect: onEndTimeSelect,
        setState: setState,
      ),
    ];
  }

  static Widget _buildDateTimeRow({
    required String label,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required Function(StateSetter) onDateSelect,
    required Function(StateSetter) onTimeSelect,
    required StateSetter setState,
  }) {
    return Row(
      children: [
        Expanded(
          child: UIComponents.buildFormField(
            controller: dateController,
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
            controller: timeController,
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

  static List<Widget> buildDropdownFields({
    required int? selectedActivityTypeId,
    required List<ActivityType> activityTypes,
    required Function(int?) onActivityTypeChanged,
    required bool isPrivate,
    required Function(bool) onVisibilityChanged,
    required String role,
    required int? selectedTroopId,
    required int? loggedInUserId,
    required Function(int?) onTroopChanged,
    required bool isEdit,
  }) {
    return [
      DropdownButtonFormField<String>(
        value: isPrivate ? 'Privatan' : 'Javan',
        decoration: const InputDecoration(
          labelText: 'Vidljivost događaja',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'Javan', child: Text('Javan')),
          DropdownMenuItem(value: 'Privatan', child: Text('Privatan')),
        ],
        onChanged: (value) => onVisibilityChanged(value == 'Privatan'),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<int>(
        value: selectedActivityTypeId,
        decoration: const InputDecoration(
          labelText: 'Odaberite osnovni tip aktivnosti',
          border: OutlineInputBorder(),
        ),
        items: activityTypes
            .map(
              (type) =>
                  DropdownMenuItem<int>(value: type.id, child: Text(type.name)),
            )
            .toList(),
        validator: (value) {
          if (value == null) {
            return 'Tip aktivnosti je obavezan';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onActivityTypeChanged,
      ),
      if (role == 'Admin' && !isEdit) ...[
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: selectedTroopId,
          decoration: const InputDecoration(
            labelText: 'Odred *',
            border: OutlineInputBorder(),
          ),
          items: [],
          validator: (value) {
            if (value == null) {
              return 'Odred je obavezan';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onTroopChanged,
        ),
      ],
    ];
  }
}
