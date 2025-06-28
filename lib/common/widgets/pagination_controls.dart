import 'dart:ui';
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
    }    final totalPages = (totalItems / limit).ceil();
    if (totalPages == 0) {
      return const SizedBox.shrink(); // Handle edge case
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            _buildPageButton(
              icon: Icons.chevron_left,
              isEnabled: currentPage > 1 && onPageChanged != null,
              onPressed: () => onPageChanged!(currentPage - 1),
              isArrow: true,
            ),
            
            // Page buttons
            for (int i = 1; i <= totalPages; i++)
              if (i == 1 || i == totalPages || (i - currentPage).abs() <= 1)
                _buildPageButton(
                  label: '$i',
                  isActive: i == currentPage,
                  onPressed: () => onPageChanged!(i),
                  isEnabled: onPageChanged != null && i != currentPage,
                )
              else if (i == currentPage - 2 || i == currentPage + 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•••', 
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
            // Next button
            _buildPageButton(
              icon: Icons.chevron_right,
              isEnabled: currentPage < totalPages && onPageChanged != null,
              onPressed: () => onPageChanged!(currentPage + 1),
              isArrow: true,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPageButton({
    String? label,
    IconData? icon,
    bool isActive = false,
    bool isArrow = false,
    bool isEnabled = true,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(10),
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: Container(
                  width: isArrow ? 36 : 40,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Colors.blue.withOpacity(0.85) 
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? Colors.blue.shade400
                          : Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(
                            icon,
                            size: 18,
                            color: isActive ? Colors.white : Colors.black87,
                          )
                        : Text(
                            label!,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}