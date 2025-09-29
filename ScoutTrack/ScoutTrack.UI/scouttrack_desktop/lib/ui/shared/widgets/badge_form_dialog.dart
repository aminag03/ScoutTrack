import 'dart:io';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/providers/badge_provider.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/url_utils.dart';

class BadgeFormDialog extends StatefulWidget {
  final Badge? badge;

  const BadgeFormDialog({super.key, this.badge});

  @override
  State<BadgeFormDialog> createState() => _BadgeFormDialogState();
}

class _BadgeFormDialogState extends State<BadgeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  File? _selectedImage;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.badge != null) {
      _nameController.text = widget.badge!.name;
      _descriptionController.text = widget.badge!.description;
      _imageUrl = widget.badge!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final compressedBytes = await ImageUtils.compressImage(bytes);
      final compressedFile = File(pickedFile.path);
      await compressedFile.writeAsBytes(compressedBytes);

      setState(() {
        _selectedImage = compressedFile;
      });
    }
  }

  Future<void> _saveBadge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final badgeProvider = BadgeProvider(authProvider);

      String finalImageUrl = _imageUrl;

      if (_selectedImage != null) {
        finalImageUrl = await badgeProvider.uploadImage(_selectedImage!);
      }

      if (widget.badge == null) {
        await badgeProvider.create(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: finalImageUrl,
        );
        if (mounted) {
          showSuccessSnackbar(context, 'Vještarstvo je uspješno kreirano');
        }
      } else {
        await badgeProvider.updateBadge(
          id: widget.badge!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: finalImageUrl,
        );
        if (mounted) {
          showSuccessSnackbar(context, 'Vještarstvo je uspješno ažurirano');
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.badge != null;

    return AlertDialog(
      title: Text(isEditing ? 'Uredi vještarstvo' : 'Dodaj novo vještarstvo'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Naziv vještarstva *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Naziv je obavezan';
                  }
                  if (value.trim().length > 100) {
                    return 'Naziv ne smije biti duži od 100 znakova';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Opis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.trim().length > 500) {
                    return 'Opis ne smije biti duži od 500 znakova';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.image, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Slika vještarstva',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Odaberi sliku'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_selectedImage != null || _imageUrl.isNotEmpty) ...[
                Container(
                  height: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedImage != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_imageUrl.isNotEmpty && _selectedImage == null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    UrlUtils.buildImageUrl(_imageUrl),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageUrl = '';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImage != null
                      ? 'Nova slika odabrana'
                      : 'Postojeća slika',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBadge,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Ažuriraj' : 'Kreiraj'),
        ),
      ],
    );
  }
}
