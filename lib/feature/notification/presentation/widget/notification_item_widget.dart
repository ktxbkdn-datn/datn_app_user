import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationItemWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;
  const NotificationItemWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  Icon _getNotificationIcon() {
    switch (notification['targetType']) {
      case 'bill':
        return const Icon(Icons.description, color: Colors.blue, size: 28);
      case 'report':
        return const Icon(Icons.description, color: Colors.orange, size: 28);
      default:
        return const Icon(Icons.notifications, color: Colors.grey, size: 28);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] == true;
    final hasMedia = notification['media'] != null && (notification['media'] as List).isNotEmpty;
    
    // Debug log for isRead in widget
    print('DEBUG: NotificationItemWidget - ID: ${notification['notificationId']}, isRead: $isRead');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isRead ? Colors.white.withOpacity(0.8) : Colors.blue.shade50.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRead ? Colors.white.withOpacity(0.3) : Colors.blue.withOpacity(0.3), 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: isRead ? Colors.black.withOpacity(0.06) : Colors.blue.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: _getNotificationIcon(),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.black87,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),                              if (!isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade500,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.shade200.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text('Mới', 
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification['targetType'] == 'bill'
                                ? 'Hóa đơn'
                                : notification['targetType'] == 'report'
                                    ? 'Báo cáo'
                                    : 'Thông báo',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['message'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 15, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(notification['createdAt'] ?? ''),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (hasMedia)
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${(notification['media'] as List).length} file đính kèm',
                                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    if (showActions)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (!isRead && onMarkAsRead != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: GestureDetector(
                                onTap: () {
                                  onMarkAsRead!();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          if (onDelete != null)
                            GestureDetector(
                              onTap: () {
                                onDelete!();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}