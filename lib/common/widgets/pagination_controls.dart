import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int limit;
  final Function(int)? onPageChanged; // Cho phép onPageChanged là null

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalItems,
    required this.limit,
    this.onPageChanged, // onPageChanged là optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (currentPage > 1 && onPageChanged != null)
              ? () => onPageChanged!(currentPage - 1) // Chỉ gọi nếu onPageChanged không null
              : null,
        ),
        Text('Trang $currentPage'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: (totalItems > currentPage * limit && onPageChanged != null)
              ? () => onPageChanged!(currentPage + 1) // Chỉ gọi nếu onPageChanged không null
              : null,
        ),
      ],
    );
  }
}