import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<Uint8List> compressImage(
    Uint8List bytes, {
    int quality = 30,
    int maxWidth = 800,
  }) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      int width = image.width;
      int height = image.height;
      if (width > maxWidth) {
        height = (height * maxWidth / width).round();
        width = maxWidth;
      }

      final resizedImage = img.copyResize(image, width: width, height: height);
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      return bytes;
    }
  }

  static Future<File?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška pri odabiru slike: $e')));
      }
      return null;
    }
  }

  static Future<Uint8List?> showImagePickerDialog({
    required BuildContext context,
    String title = 'Odaberi sliku',
    String? currentImageUrl,
    bool isCircular = false,
  }) async {
    Uint8List? selectedImageBytes;
    File? selectedImageFile;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedImageBytes != null ||
                      currentImageUrl?.isNotEmpty == true)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(
                              isCircular ? 100 : 8,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              isCircular ? 100 : 8,
                            ),
                            child: selectedImageBytes != null
                                ? Image.memory(
                                    selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : (currentImageUrl?.isNotEmpty == true
                                      ? Image.network(
                                          currentImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    isCircular
                                                        ? Icons.person
                                                        : Icons.broken_image,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                        )
                                      : Center(
                                          child: Icon(
                                            isCircular
                                                ? Icons.person
                                                : Icons.image,
                                            size: 50,
                                          ),
                                        )),
                          ),
                        ),
                        if (selectedImageBytes != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageBytes = null;
                                  selectedImageFile = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(
                          isCircular ? 100 : 8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isCircular ? Icons.person : Icons.image,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final imageFile = await pickImage(context: context);
                      if (imageFile != null) {
                        final bytes = await imageFile.readAsBytes();
                        final compressedBytes = await compressImage(bytes);
                        setState(() {
                          selectedImageBytes = compressedBytes;
                          selectedImageFile = imageFile;
                        });
                      }
                    },
                    child: const Text('Odaberi sliku'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  selectedImageBytes = null;
                  selectedImageFile = null;
                  Navigator.of(context).pop(false);
                },
                child: const Text('Otkaži'),
              ),
              ElevatedButton(
                onPressed: selectedImageBytes != null
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text('Sačuvaj'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      return selectedImageBytes;
    }
    return null;
  }

  static Future<bool> showDeleteImageConfirmation({
    required BuildContext context,
    String title = 'Obriši sliku',
    String message = 'Jeste li sigurni da želite obrisati sliku?',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
