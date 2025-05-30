import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationItemWidget extends StatelessWidget {
  final String title;
  final String message;
  final List<String> mediaUrls;
  final String timestamp;
  final String type;
  final VoidCallback onTap;
  final bool isCompact; // True for compact view (NotificationListScreen), false for full view (HomeScreen)
  final double? mediaHeight; // For full view in HomeScreen

  const NotificationItemWidget({
    super.key,
    required this.title,
    required this.message,
    required this.mediaUrls,
    required this.timestamp,
    required this.type,
    required this.onTap,
    this.isCompact = false,
    this.mediaHeight,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'bill':
        return Icons.receipt; // Icon cho thông báo hóa đơn
      case 'report':
        return Icons.report; // Icon cho thông báo về report
      case 'general':
      default:
        return Icons.notifications; // Icon cho thông báo chung
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      // Compact view for NotificationListScreen
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIconForType(type),
                size: 30,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == 'bill'
                          ? 'Bill'
                          : type == 'report'
                          ? 'Report'
                          : 'General',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Full view for HomeScreen
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Pagination
              SizedBox(
                height: mediaHeight,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: mediaUrls.length,
                      itemBuilder: (context, pageIndex) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            mediaUrls[pageIndex],
                            width: double.infinity,
                            height: mediaHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: mediaHeight,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (mediaUrls.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            mediaUrls.length,
                                (dotIndex) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}