import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final Function(int) onPageChanged;
  final int maxPageButtons;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.onPageChanged,
    this.maxPageButtons = 5,
  });

  @override
  Widget build(BuildContext context) {
    int safeTotalPages = totalPages > 0 ? totalPages : 1;
    int safeCurrentPage = currentPage > 0 ? currentPage : 1;
    int startPage = (safeCurrentPage - (maxPageButtons ~/ 2)).clamp(
      1,
      (safeTotalPages - maxPageButtons + 1).clamp(1, safeTotalPages),
    );
    int endPage = (startPage + maxPageButtons - 1).clamp(1, safeTotalPages);
    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];
    bool hasResults = totalCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: hasResults && safeCurrentPage > 1
                ? () => onPageChanged(1)
                : null,
          ),
          TextButton(
            onPressed: hasResults && safeCurrentPage > 1
                ? () => onPageChanged(safeCurrentPage - 1)
                : null,
            child: const Text('Prethodna'),
          ),
          ...pageNumbers.map(
            (page) => TextButton(
              onPressed: hasResults && page != safeCurrentPage
                  ? () => onPageChanged(page)
                  : null,
              child: Text(
                '$page',
                style: TextStyle(
                  fontWeight: page == safeCurrentPage
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: page == safeCurrentPage ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => onPageChanged(safeCurrentPage + 1)
                : null,
            child: const Text('Sljedeća'),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => onPageChanged(safeTotalPages)
                : null,
          ),
        ],
      ),
    );
  }
}
