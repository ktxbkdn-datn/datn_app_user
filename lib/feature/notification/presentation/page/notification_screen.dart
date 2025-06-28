import 'dart:ui';
import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/common/widgets/pagination_controls.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/colors.dart';
import '../../../../common/widgets/filter_tab.dart';
import '../../domain/entity/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widget/notification_item_widget.dart';
import 'notification_detail_screen.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialLoad = true;
  bool _isLoading = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingUnreadCount = false;
  int _unreadCount = 0;
  String _filterType = 'Chưa đọc';
  List<Notification> _personalNotifications = [];
  int _currentPage = 1;
  int _totalItems = 0;
  static const int _limit = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
    _fetchNotifications();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('notification_current_page') ?? 1;
    });
  }

  Future<void> _savePersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_current_page', _currentPage);
  }
  void _fetchNotifications({int page = 1, bool clearCache = false}) {
    setState(() {
      _isLoading = true;
      _isLoadingNotifications = true;
      _isLoadingUnreadCount = true;
      _currentPage = page;
    });
    if (clearCache) {
      context.read<NotificationBloc>().add(const ClearCacheEvent());
    }
    context.read<NotificationBloc>().add(
          FetchUserNotificationsEvent(page: page, limit: _limit, isRead: null),
        );
    context.read<NotificationBloc>().add(const FetchUnreadNotificationsCountEvent());
    _savePersistedState();
  }
  void _updateLoadingState() {
    if (!_isLoadingNotifications && !_isLoadingUnreadCount) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and refresh button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title with unread count
                        Text(
                          "Thông báo ($_unreadCount chưa đọc)",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(context, 22),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                        Row(
                          children: [
                            // Nút đánh dấu tất cả đã đọc
                            if (_unreadCount > 0)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.done_all, color: Colors.white, size: 24),
                                      tooltip: 'Đánh dấu tất cả đã đọc',
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              // Gửi event cho bloc
                                              context.read<NotificationBloc>().add(MarkAllNotificationsAsReadEvent());
                                              // Cập nhật UI ngay (optimistic update)
                                              setState(() {
                                                for (var i = 0; i < _personalNotifications.length; i++) {
                                                  _personalNotifications[i] = _personalNotifications[i].copyWith(isRead: true);
                                                }
                                                _unreadCount = 0;
                                              });
                                            },
                                      iconSize: ResponsiveUtils.sp(context, 24),
                                      padding: EdgeInsets.all(ResponsiveUtils.sp(context, 8)),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Nút refresh
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: _isLoading
                                    ? null
                                    : () => _fetchNotifications(page: _currentPage, clearCache: true),
                                iconSize: ResponsiveUtils.sp(context, 24),
                                padding: EdgeInsets.all(ResponsiveUtils.sp(context, 8)),
                              ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Filter tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FilterTabBar(
                      filters: [
                        {'label': 'Chưa đọc', 'type': 'Chưa đọc'},
                        {'label': 'Đã đọc', 'type': 'Đã đọc'},
                      ],
                      activeFilter: _filterType,
                      onFilterChange: (String filterType) {
                        setState(() {
                          _filterType = filterType;
                        });
                      },
                      unreadCount: _unreadCount,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Notifications list
                  Expanded(
                    child: BlocConsumer<NotificationBloc, NotificationState>(
                      listener: (context, state) {
                        if (state is NotificationError) {
                          // Nếu vừa gửi MarkAllNotificationsAsReadEvent thì rollback optimistic update
                          if (state.message.contains('Lỗi khi lưu thay đổi')) {
                            setState(() {
                              // Đánh dấu lại các thông báo chưa đọc về trạng thái cũ
                              for (var i = 0; i < _personalNotifications.length; i++) {
                                if (!_personalNotifications[i].isRead) {
                                  _personalNotifications[i] = _personalNotifications[i].copyWith(isRead: false);
                                }
                              }
                              // Đếm lại số chưa đọc
                              _unreadCount = _personalNotifications.where((n) => !n.isRead).length;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.message.contains('Failed to fetch')
                                    ? 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại.'
                                    : state.message,
                              ),
                              action: SnackBarAction(
                                label: 'Thử lại',
                                onPressed: () => _fetchNotifications(page: _currentPage, clearCache: true),
                              ),
                            ),
                          );
                          setState(() {
                            _isLoadingNotifications = false;
                            _isLoadingUnreadCount = false;
                            _updateLoadingState();
                          });
                        } else if (state is UserNotificationsLoaded) {
                          setState(() {
                            _personalNotifications = state.notifications;
                            _totalItems = state.totalItems;
                            _isInitialLoad = false;
                            _isLoadingNotifications = false;
                            _updateLoadingState();
                          });
                        } else if (state is NotificationMarkedAsRead) {
                          _fetchNotifications(page: _currentPage);
                        } else if (state is UnreadNotificationsCountLoaded) {
                          setState(() {
                            _unreadCount = state.count;
                            _isLoadingUnreadCount = false;
                            _updateLoadingState();
                          });
                        } else if (state is NotificationDeleted) {
                          // Always reload the current page after a delete
                          _fetchNotifications(page: _currentPage);
                        } else if (state is NewFcmNotification) {
                          _fetchNotifications(page: 1);
                        }
                      },
                      builder: (context, state) {
                        // Debug: Print the isRead status of all notifications
                        print('DEBUG: Total notifications in _personalNotifications: ${_personalNotifications.length}');
                        for (var notification in _personalNotifications) {
                          print('DEBUG: Notification ID: ${notification.notificationId}, isRead: ${notification.isRead}, Title: "${notification.title}"');
                        }
                        
                        List<Notification> notifications = [];
                        // For the API response, isRead: true means "has been read"
                        if (_filterType == 'Chưa đọc') {
                          // API shows isRead=true for notifications that have been read
                          notifications = _personalNotifications.where((n) => n.isRead == false).toList();
                          print('DEBUG: "Chưa đọc" filter - ${notifications.length} notifications after filtering');
                          for (var n in notifications) {
                            print('DEBUG: Unread notification: ID ${n.notificationId}, Title: "${n.title}"');
                          }
                        } else if (_filterType == 'Đã đọc') {
                          notifications = _personalNotifications.where((n) => n.isRead == true).toList();
                          print('DEBUG: "Đã đọc" filter - ${notifications.length} notifications after filtering');
                        } else if (_filterType == 'Tất cả') {
                          notifications = _personalNotifications;
                          print('DEBUG: "Tất cả" filter - ${notifications.length} notifications');
                        }

                        // Remove duplicates based on notificationId
                        final seenIds = <int>{};
                        notifications = notifications.where((notification) {
                          if (notification.notificationId == null) {
                            return false;
                          }
                          return seenIds.add(notification.notificationId!);
                        }).toList();

                        // Sort by createdAt (descending)
                        notifications.sort((a, b) {
                          final dateA = DateTime.tryParse(a.createdAt ?? '1970-01-01') ?? DateTime(1970);
                          final dateB = DateTime.tryParse(b.createdAt ?? '1970-01-01') ?? DateTime(1970);
                          return dateB.compareTo(dateA);
                        });

                        // Debug: Print the count of filtered notifications
                        print('DEBUG: Filtered notifications count: ${notifications.length}');
                        print('DEBUG: Current filter: $_filterType');
                        
                        if (_isLoading && _isInitialLoad) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }                        if (notifications.isEmpty && state is NotificationError) {
                          return Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 50),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Không thể tải thông báo',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => _fetchNotifications(page: _currentPage, clearCache: true),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        ),
                                        child: const Text('Thử lại'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        if (notifications.isEmpty) {
                          return Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _filterType == 'Chưa đọc'
                                            ? Icons.mark_email_read
                                            : Icons.notifications_off,
                                        color: Colors.grey,
                                        size: 50
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _filterType == 'Chưa đọc'
                                            ? 'Không có thông báo chưa đọc'
                                            : _filterType == 'Đã đọc'
                                                ? 'Không tìm thấy thông báo đã đọc'
                                                : 'Không tìm thấy thông báo',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      if (_filterType == 'Chưa đọc' && _personalNotifications.isNotEmpty)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _filterType = 'Đã đọc';
                                            });
                                          },
                                          child: const Text('Xem thông báo đã đọc'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: notifications.length,                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return NotificationItemWidget(
                                    notification: {
                                      'notificationId': notification.notificationId,
                                      'title': notification.title,
                                      'message': notification.message,
                                      'createdAt': notification.createdAt,
                                      'isRead': notification.isRead,
                                      'recipientId': notification.recipientId,
                                      'targetType': notification.targetType,
                                      'isDeleted': notification.isDeleted,
                                      'media': notification.media != null ? notification.media!.map((media) => {
                                        'media_id': media.mediaId,
                                        'media_url': media.mediaUrl,
                                        'file_type': media.fileType,
                                      }).toList() : [],
                                    },
                                    onTap: () async {
                                      if (!notification.isRead && notification.notificationId != null) {
                                        setState(() {
                                          final index = _personalNotifications.indexWhere((n) => n.notificationId == notification.notificationId);
                                          if (index != -1) {
                                            _personalNotifications[index] = Notification(
                                              notificationId: notification.notificationId,
                                              title: notification.title,
                                              message: notification.message,
                                              createdAt: notification.createdAt,
                                              isRead: true,
                                              recipientId: notification.recipientId,
                                              targetType: notification.targetType,
                                              isDeleted: notification.isDeleted,
                                            );
                                          }
                                        });
                                        context.read<NotificationBloc>().add(
                                              MarkNotificationAsReadEvent(notificationId: notification.notificationId!),
                                            );
                                      }
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NotificationDetailScreen(
                                            title: notification.title,
                                            message: notification.message,
                                            timestamp: notification.createdAt ?? '',
                                            notificationId: notification.notificationId!,
                                            recipientId: notification.recipientId,
                                          ),
                                        ),
                                      );
                                      _fetchNotifications(page: _currentPage);
                                    },
                                    onMarkAsRead: notification.isRead ? null : () {
                                      setState(() {
                                        final index = _personalNotifications.indexWhere((n) => n.notificationId == notification.notificationId);
                                        if (index != -1) {
                                          _personalNotifications[index] = Notification(
                                            notificationId: notification.notificationId,
                                            title: notification.title,
                                            message: notification.message,
                                            createdAt: notification.createdAt,
                                            isRead: true,
                                            recipientId: notification.recipientId,
                                            targetType: notification.targetType,
                                            isDeleted: notification.isDeleted,
                                          );
                                        }
                                      });
                                      context.read<NotificationBloc>().add(
                                            MarkNotificationAsReadEvent(
                                              notificationId: notification.notificationId!,
                                            ),
                                          );
                                    },
                                    onDelete: () {
                                      setState(() {
                                        _personalNotifications.removeWhere((n) => n.notificationId == notification.notificationId);
                                      });
                                      context.read<NotificationBloc>().add(
                                        DeleteNotificationEvent(notificationId: notification.notificationId!),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Pagination controls with glassmorphism
                            if (_totalItems > _limit)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalItems: _totalItems,
                                      limit: _limit,
                                      onPageChanged: (page) {
                                        _fetchNotifications(page: page, clearCache: true);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (_isLoading && !_isInitialLoad)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}