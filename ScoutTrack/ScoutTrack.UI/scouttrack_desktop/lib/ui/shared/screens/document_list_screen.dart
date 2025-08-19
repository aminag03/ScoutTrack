import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scouttrack_desktop/models/document.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/document_provider.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  SearchResult<Document>? _documents;
  bool _isLoading = false;
  bool _isUploading = false;
  File? _selectedFile;
  String? _selectedFileName;
  String? _userRole;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _initializeUserRole().then((_) {
      _loadDocuments();
    });
  }

  Future<void> _initializeUserRole() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userInfo = await authProvider.getCurrentUserInfo();
      if (userInfo != null && userInfo['role'] != null) {
        final role = userInfo['role'] as String;
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool get isAdmin => _userRole == 'Admin';
  bool get isTroop => _userRole == 'Troop';
  bool get isRoleDetermined => _userRole != null;

  Future<void> _loadDocuments({int? page}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final documentProvider = DocumentProvider(authProvider);

      final result = await documentProvider.get(
        filter: {
          'FTS': _searchController.text,
          'Page': page ?? _currentPage,
          'PageSize': _pageSize,
        },
      );

      setState(() {
        _documents = result;
        _isLoading = false;
        if (page != null) {
          _currentPage = page;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _downloadDocument(Document document) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final documentProvider = DocumentProvider(authProvider);

      final extension = document.filePath.split('.').last;
      final fileName = '${document.title}.$extension';

      await documentProvider.downloadDocument(document.id, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dokument "$fileName" uspješno preuzet!'),
                const SizedBox(height: 4),
                Text(
                  'Datoteka spremljena u: Downloads/',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _clearUploadForm() {
    setState(() {
      _titleController.clear();
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  void _showValidationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      _showValidationError("Molimo odaberite datoteku.");
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showValidationError("Molimo unesite naslov dokumenta.");
      return;
    }

    if (_titleController.text.length > 100) {
      _showValidationError(
        "Naslov dokumenta ne smije imati više od 100 znakova.",
      );
      return;
    }

    final fileSizeInMB = _selectedFile!.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > 10) {
      _showValidationError(
        "Datoteka je prevelika. Maksimalna veličina je 10MB.",
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final documentProvider = DocumentProvider(authProvider);

      final fileName = await documentProvider.uploadDocument(_selectedFile!);

      await documentProvider.insert({
        'Title': _titleController.text.trim(),
        'FilePath': fileName,
      });

      _clearUploadForm();

      if (_documents != null && _documents!.totalCount != null) {
        final totalPages = _calculateTotalPages();
        _currentPage = totalPages - 1;
      } else {
        _currentPage = 0;
      }

      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dokument uspješno učitan!'),
                const SizedBox(height: 4),
                Text(
                  'Preusmjereno na zadnju stranicu da vidite novi dokument.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _editDocument(Document document) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final documentProvider = DocumentProvider(authProvider);

      final fileExists = await documentProvider.documentFileExists(document.id);
      if (!fileExists) {
        if (mounted) {
          _showValidationError(
            "Datoteka za ovaj dokument ne postoji. Dokument se ne može uređivati.",
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        _showValidationError(
          "Greška prilikom provjere postojanja datoteke: $e",
        );
      }
      return;
    }

    final TextEditingController editTitleController = TextEditingController(
      text: document.title,
    );
    File? newFile;
    String? newFileName;
    bool hasValidDocument = true;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          hasValidDocument =
              editTitleController.text.trim().isNotEmpty &&
              editTitleController.text.length <= 100;

          return AlertDialog(
            title: const Text('Uredi dokument'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editTitleController,
                    decoration: InputDecoration(
                      labelText: 'Naslov dokumenta',
                      border: const OutlineInputBorder(),
                      errorText: editTitleController.text.trim().isEmpty
                          ? 'Naslov je obavezan'
                          : editTitleController.text.length > 100
                          ? 'Naslov ne smije imati više od 100 znakova'
                          : null,
                      counterText: '${editTitleController.text.length}/100',
                    ),
                    maxLength: 100,
                    onChanged: (value) {
                      setDialogState(() {
                        hasValidDocument =
                            value.trim().isNotEmpty && value.length <= 100;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Datoteka: ${_getFileDisplayName(document.filePath)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        FilePickerResult? pickResult = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'pdf',
                                'doc',
                                'docx',
                                'txt',
                                'jpg',
                                'jpeg',
                                'png',
                              ],
                              allowMultiple: false,
                            );

                        if (pickResult != null) {
                          setDialogState(() {
                            newFile = File(pickResult.files.single.path!);
                            newFileName = pickResult.files.single.name;
                          });
                        }
                      } catch (e) {
                        _showValidationError(
                          'Greška prilikom odabira datoteke: $e',
                        );
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Odaberi novu datoteku'),
                  ),
                  if (newFileName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_present,
                            color: Colors.green[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nova datoteka: $newFileName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Veličina: ${_formatFileSize(newFile!.lengthSync())}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasValidDocument
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: hasValidDocument
                            ? Colors.green[200]!
                            : Colors.orange[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasValidDocument ? Icons.check_circle : Icons.info,
                          color: hasValidDocument
                              ? Colors.green[600]
                              : Colors.orange[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasValidDocument
                                ? 'Spremno za spremanje'
                                : editTitleController.text.trim().isEmpty
                                ? 'Unesite naslov dokumenta'
                                : 'Naslov je predugačak (max 100 znakova)',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasValidDocument
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Odustani'),
              ),
              ElevatedButton(
                onPressed: hasValidDocument
                    ? () {
                        if (editTitleController.text.trim().isNotEmpty) {
                          Navigator.of(context).pop({
                            'title': editTitleController.text.trim(),
                            'newFile': newFile,
                            'newFileName': newFileName,
                          });
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasValidDocument
                      ? Colors.green[600]
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Spremi'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      try {
        if (result['title'].trim().isEmpty) {
          _showValidationError("Naslov dokumenta ne smije biti prazan.");
          return;
        }

        if (result['title'].length > 100) {
          _showValidationError(
            "Naslov dokumenta ne smije imati više od 100 znakova.",
          );
          return;
        }

        if (result['newFile'] != null) {
          final fileSizeInMB = result['newFile'].lengthSync() / (1024 * 1024);
          if (fileSizeInMB > 10) {
            _showValidationError(
              "Datoteka je prevelika. Maksimalna veličina je 10MB.",
            );
            return;
          }
        }

        setState(() {
          _isUploading = true;
        });

        final authProvider = context.read<AuthProvider>();
        final documentProvider = DocumentProvider(authProvider);

        String newFilePath = document.filePath;

        if (result['newFile'] != null) {
          try {
            final uploadedFileName = await documentProvider.uploadDocument(
              result['newFile'],
            );
            newFilePath = uploadedFileName;
          } catch (e) {
            if (mounted) {
              showErrorSnackbar(
                context,
                'Greška prilikom učitavanja nove datoteke: $e',
              );
            }
            return;
          }
        }

        await documentProvider.update(document.id, {
          'Title': result['title'],
          'FilePath': newFilePath,
        });

        await _loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokument uspješno ažuriran!')),
          );
        }
      } catch (e) {
        if (mounted) {
          showErrorSnackbar(context, e);
        }
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati dokument "${document.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        final documentProvider = DocumentProvider(authProvider);

        await documentProvider.delete(document.id);
        await _loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokument uspješno obrisan!')),
          );
        }
      } catch (e) {
        if (mounted) {
          showErrorSnackbar(context, e);
        }
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showValidationError('Greška prilikom odabira datoteke: $e');
    }
  }

  void _onPageChanged(int page) {
    _loadDocuments(page: page - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!isRoleDetermined) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = _userRole!;

    return MasterScreen(
      role: role,
      selectedMenu: 'Dokumenti',
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Pretraži dokumente...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _currentPage = 0;
                        _loadDocuments(page: 0);
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (isRoleDetermined && isAdmin) ...[
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upload, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Dodaj novi dokument',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Unesite naslov dokumenta',
                              border: const OutlineInputBorder(),
                              labelText: 'Naslov',
                              errorText: _titleController.text.length > 100
                                  ? 'Naslov ne smije imati više od 100 znakova'
                                  : null,
                              counterText:
                                  '${_titleController.text.length}/100',
                            ),
                            maxLength: 100,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Odaberi datoteku'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.file_present, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Odabrana datoteka: $_selectedFileName',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Veličina: ${_formatFileSize(_selectedFile!.lengthSync())}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final isButtonEnabled =
                                  _selectedFile != null &&
                                  _titleController.text.trim().isNotEmpty &&
                                  _titleController.text.length <= 100 &&
                                  !_isUploading;

                              return ElevatedButton.icon(
                                onPressed: isButtonEnabled
                                    ? _uploadDocument
                                    : null,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.upload),
                                label: Text(
                                  _isUploading
                                      ? 'Učitavanje...'
                                      : 'Učitaj dokument',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isButtonEnabled
                                      ? Colors.green[600]
                                      : Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _clearUploadForm,
                          icon: const Icon(Icons.clear),
                          label: const Text('Očisti'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (_selectedFile != null &&
                                _titleController.text.trim().isNotEmpty &&
                                _titleController.text.length <= 100)
                            ? Colors.green[50]
                            : _titleController.text.length > 100
                            ? Colors.red[50]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              (_selectedFile != null &&
                                  _titleController.text.trim().isNotEmpty &&
                                  _titleController.text.length <= 100)
                              ? Colors.green[200]!
                              : _titleController.text.length > 100
                              ? Colors.red[200]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_selectedFile != null &&
                                    _titleController.text.trim().isNotEmpty &&
                                    _titleController.text.length <= 100)
                                ? Icons.check_circle
                                : _titleController.text.length > 100
                                ? Icons.error
                                : Icons.info_outline,
                            color:
                                (_selectedFile != null &&
                                    _titleController.text.trim().isNotEmpty &&
                                    _titleController.text.length <= 100)
                                ? Colors.green[600]
                                : _titleController.text.length > 100
                                ? Colors.red[600]
                                : Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile == null
                                  ? 'Odaberite datoteku'
                                  : _titleController.text.trim().isEmpty
                                  ? 'Unesite naslov dokumenta'
                                  : _titleController.text.length > 100
                                  ? 'Naslov je predug (max 100 znakova)'
                                  : 'Spremno za učitavanje',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    (_selectedFile != null &&
                                        _titleController.text
                                            .trim()
                                            .isNotEmpty &&
                                        _titleController.text.length <= 100)
                                    ? Colors.green[700]
                                    : _titleController.text.length > 100
                                    ? Colors.red[700]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (_documents != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prikazano ${_documents!.items?.length ?? 0} od ukupno ${_documents!.totalCount ?? 0} dokumenata',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (_documents?.items?.isEmpty == true)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Nema dokumenata',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else if (_documents?.items != null)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio:
                                    0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: _documents!.items!.length,
                          itemBuilder: (context, index) {
                            final document = _documents!.items![index];
                            return _buildDocumentCard(document);
                          },
                        ),

                      if (_documents != null && _documents!.totalCount != null)
                        PaginationControls(
                          currentPage: _currentPage + 1,
                          totalPages: _calculateTotalPages(),
                          totalCount: _documents!.totalCount!,
                          onPageChanged: _onPageChanged,
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              document.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: Icon(
                  Icons.description,
                  size: 56,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (isAdmin) ...[
              Text(
                'Dodao: ${document.adminFullName}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],

            Text(
              formatDate(document.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _downloadDocument(document),
                  icon: const Icon(
                    Icons.download,
                    color: Colors.blue,
                    size: 24,
                  ),
                  tooltip: 'Preuzmi',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),

                if (isAdmin) ...[
                  IconButton(
                    onPressed: () => _editDocument(document),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: 24,
                    ),
                    tooltip: 'Uredi',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteDocument(document),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                    tooltip: 'Obriši',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFileDisplayName(String filePath) {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;

    if (fileName.length > 20 && fileName.contains('-')) {
      final extension = fileName.split('.').last;
      return '.$extension';
    }

    return fileName;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    }
  }

  int _calculateTotalPages() {
    if (_documents?.totalCount == null) return 1;
    return (_documents!.totalCount! / _pageSize)
        .ceil()
        .clamp(1, double.infinity)
        .toInt();
  }
}