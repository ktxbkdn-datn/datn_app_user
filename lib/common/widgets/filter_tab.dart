import 'dart:ui';
import 'package:flutter/material.dart';

class FilterTabBar extends StatelessWidget {
  final List<Map<String, dynamic>> filters;
  final String activeFilter;
  final Function(String) onFilterChange;
  final int unreadCount;
  const FilterTabBar({
    Key? key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChange,
    required this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: filters.map((filter) {
          final bool isActive = activeFilter == filter['type'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onFilterChange(filter['type']),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.blue.shade600.withOpacity(0.95)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.blue.shade600 : Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (isActive)
                          BoxShadow(
                            color: Colors.blue.shade100.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          filter['label'],
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),                        ),
                        if (filter['type'] == 'Chưa đọc' && unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}