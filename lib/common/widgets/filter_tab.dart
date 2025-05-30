import 'package:flutter/material.dart';

class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap; // Cho phép onTap là null

  const FilterTab({
    Key? key,
    required this.label,
    required this.isSelected,
    this.onTap, // onTap là optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {}, // Cung cấp giá trị mặc định nếu onTap là null
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}