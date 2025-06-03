import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int limit;
  final Function(int)? onPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalItems,
    required this.limit,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) {
      return const SizedBox.shrink(); // Return empty widget if no items
    }

    final totalPages = (totalItems / limit).ceil();
    if (totalPages == 0) {
      return const SizedBox.shrink(); // Handle edge case
    }

    final maxVisiblePages = 2;
    final startPage = (currentPage - (maxVisiblePages ~/ 2)).clamp(1, totalPages);
    final endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: (currentPage > 1 && onPageChanged != null) ? () => onPageChanged!(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentPage > 1 && onPageChanged != null) ? () => onPageChanged!(currentPage - 1) : null,
          ),
          for (int i = startPage; i <= endPage; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: i == currentPage ? Colors.lightGreenAccent : Colors.grey[200],
                  foregroundColor: i == currentPage ? Colors.black : Colors.black,
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: i == currentPage ? Colors.black : Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: (onPageChanged != null) ? () => onPageChanged!(i) : null,
                child: Text('$i'),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: (currentPage < totalPages && onPageChanged != null) ? () => onPageChanged!(currentPage + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: (currentPage < totalPages && onPageChanged != null) ? () => onPageChanged!(totalPages) : null,
          ),
        ],
      ),
    );
  }
}