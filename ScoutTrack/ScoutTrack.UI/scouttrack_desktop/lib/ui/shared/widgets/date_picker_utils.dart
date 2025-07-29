import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';

class DatePickerUtils {
  /// Shows a date picker dialog using SfDateRangePicker
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Odaberite datum',
  }) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          height: 400,
          child: SfDateRangePicker(
            initialSelectedDate: initialDate,
            minDate: minDate ?? DateTime(1900),
            maxDate: maxDate ?? DateTime.now(),
            selectionMode: DateRangePickerSelectionMode.single,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is DateTime) {
                Navigator.pop(context, args.value as DateTime);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
        ],
      ),
    );

    return picked;
  }

  /// Shows a date picker dialog using Flutter's built-in showDatePicker
  static Future<DateTime?> showFlutterDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
    );

    return picked;
  }

  /// Creates a date picker form field with calendar icon
  static Widget createDatePickerField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
    String? Function(String?)? validator,
    bool readOnly = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: readOnly,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }

  /// Shows a date picker and updates the controller with formatted date
  static Future<void> showDatePickerAndUpdate({
    required BuildContext context,
    required TextEditingController controller,
    required DateTime initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Odaberite datum',
    required StateSetter setState,
  }) async {
    final DateTime? picked = await showDatePickerDialog(
      context: context,
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      title: title,
    );

    if (picked != null) {
      setState(() {
        controller.text = formatDate(picked);
      });
    }
  }

  /// Validates if a date string is not empty
  static String? validateRequiredDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Datum je obavezan.';
    }
    return null;
  }

  /// Validates if a date is within a specific range
  static String? validateDateRange(
    String? value,
    DateTime? minDate,
    DateTime? maxDate,
  ) {
    if (value == null || value.isEmpty) {
      return 'Datum je obavezan.';
    }

    try {
      final date = parseDate(value);
      if (minDate != null && date.isBefore(minDate)) {
        return 'Datum ne smije biti prije ${formatDate(minDate)}.';
      }
      if (maxDate != null && date.isAfter(maxDate)) {
        return 'Datum ne smije biti nakon ${formatDate(maxDate)}.';
      }
    } catch (e) {
      return 'Unesite ispravan datum.';
    }

    return null;
  }
}
