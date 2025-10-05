import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_mobile/models/document.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';
import 'package:scouttrack_mobile/providers/document_provider.dart';
import 'package:scouttrack_mobile/models/search_result.dart';
import 'package:scouttrack_mobile/utils/snackbar_utils.dart';
import 'package:scouttrack_mobile/layouts/master_screen.dart';
import 'package:intl/intl.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchResult<Document>? _documents;
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        SnackBarUtils.showErrorSnackBar(
          'Greška pri učitavanju dokumenata: ${e.toString()}',
        );
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
        String downloadPath = '';
        if (Platform.isAndroid) {
          downloadPath = '/storage/emulated/0/Download/$fileName';
        } else if (Platform.isIOS) {
          downloadPath = 'Documents/$fileName';
        } else {
          downloadPath = 'Documents/$fileName';
        }

        SnackBarUtils.showSuccessSnackBar(
          'Dokument je uspješno preuzet!\nLokacija: $downloadPath',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(
          'Greška pri preuzimanju dokumenta: ${e.toString()}',
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  void _onSearchChanged(String value) {
    _currentPage = 0;
    _loadDocuments(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Izviđački dokumenti',
      showBackButton: true,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pretraži dokumente...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          if (_documents != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              margin: const EdgeInsets.all(16),
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

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents?.items?.isEmpty == true
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nema dokumenata',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
                : _documents?.items != null
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents!.items!.length,
                    itemBuilder: (context, index) {
                      final document = _documents!.items![index];
                      return _buildDocumentCard(document);
                    },
                  )
                : const SizedBox.shrink(),
          ),

          if (_documents != null &&
              _documents!.totalCount != null &&
              _documents!.totalCount! > _pageSize)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 0
                        ? () => _loadDocuments(page: _currentPage - 1)
                        : null,
                    child: const Text('Prethodna'),
                  ),
                  Text(
                    'Stranica ${_currentPage + 1} od ${(_documents!.totalCount! / _pageSize).ceil()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton(
                    onPressed:
                        _currentPage <
                            (_documents!.totalCount! / _pageSize).ceil() - 1
                        ? () => _loadDocuments(page: _currentPage + 1)
                        : null,
                    child: const Text('Sljedeća'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(document.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _downloadDocument(document),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Preuzmi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
