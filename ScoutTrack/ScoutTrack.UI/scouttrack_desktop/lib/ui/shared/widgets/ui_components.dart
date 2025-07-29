import 'package:flutter/material.dart';

class UIComponents {
  /// Creates an info chip widget
  static Widget buildInfoChip(String text, IconData icon, {Color? color}) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(text),
      backgroundColor: Colors.grey[100],
      side: BorderSide.none,
    );
  }

  /// Creates a detail section widget
  static Widget buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Creates a detail row widget
  static Widget buildDetailRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  /// Creates a big action button widget
  static Widget buildBigActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    double width = 200,
    double height = 80,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a confirmation dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Odustani',
    String confirmText = 'Potvrdi',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(color: isDestructive ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Creates a delete confirmation dialog
  static Future<bool> showDeleteConfirmationDialog({
    required BuildContext context,
    required String itemName,
    String itemType = 'stavku',
  }) async {
    return showConfirmationDialog(
      context: context,
      title: 'Potvrda brisanja',
      message: 'Jeste li sigurni da želite obrisati $itemType "$itemName"?',
      confirmText: 'Obriši',
      isDestructive: true,
    );
  }

  /// Creates an activation/deactivation confirmation dialog
  static Future<bool> showActivationConfirmationDialog({
    required BuildContext context,
    required bool isActive,
    required String itemName,
    String itemType = 'stavku',
  }) async {
    return showConfirmationDialog(
      context: context,
      title: isActive ? 'Deaktivacija' : 'Aktivacija',
      message: isActive
          ? 'Da li ste sigurni da želite deaktivirati $itemType "$itemName"?'
          : 'Da li ste sigurni da želite aktivirati $itemType "$itemName"?',
    );
  }

  /// Creates a loading overlay
  static Widget buildLoadingOverlay({
    required bool isLoading,
    required Widget child,
    Color? backgroundColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  /// Creates a search field
  static Widget buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onChanged,
    EdgeInsets padding = const EdgeInsets.only(right: 12),
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  /// Creates a dropdown form field
  static Widget buildDropdownField<T>({
    required T? value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
    EdgeInsets padding = const EdgeInsets.only(right: 12),
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        isExpanded: true,
        onChanged: onChanged,
        items: items,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  /// Creates a form field with standard styling
  static Widget buildFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    EdgeInsets padding = const EdgeInsets.only(bottom: 12),
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
