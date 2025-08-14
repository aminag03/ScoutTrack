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
          // First page button
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: hasResults && safeCurrentPage > 1
                ? () => onPageChanged(1)
                : null,
            color: hasResults && safeCurrentPage > 1
                ? const Color(0xFF4F8055)
                : Colors.grey.shade400,
          ),

          TextButton(
            onPressed: hasResults && safeCurrentPage > 1
                ? () => onPageChanged(safeCurrentPage - 1)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: hasResults && safeCurrentPage > 1
                  ? const Color(0xFF4F8055)
                  : Colors.grey.shade400,
            ),
            child: const Text('Prethodna'),
          ),

          const SizedBox(width: 16),

          ...pageNumbers.map(
            (page) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: hasResults && page != safeCurrentPage
                      ? () => onPageChanged(page)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: page == safeCurrentPage
                          ? const Color(0xFF4F8055)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: page == safeCurrentPage
                            ? const Color(0xFF4F8055)
                            : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: page == safeCurrentPage
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4F8055).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$page',
                        style: TextStyle(
                          color: page == safeCurrentPage
                              ? Colors.white
                              : Colors.black,
                          fontWeight: page == safeCurrentPage
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          TextButton(
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => onPageChanged(safeCurrentPage + 1)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: hasResults && safeCurrentPage < safeTotalPages
                  ? const Color(0xFF4F8055)
                  : Colors.grey.shade400,
            ),
            child: const Text('Sljedeća'),
          ),

          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: hasResults && safeCurrentPage < safeTotalPages
                ? () => onPageChanged(safeTotalPages)
                : null,
            color: hasResults && safeCurrentPage < safeTotalPages
                ? const Color(0xFF4F8055)
                : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}