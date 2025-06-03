import 'package:datn_app/common/widgets/pagination_controls.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/colors.dart';
import '../../../../common/widgets/filter_tab.dart';
import '../../domain/entity/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
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

  void _fetchNotifications({int page = 1}) {
    setState(() {
      _isLoading = true;
      _isLoadingNotifications = true;
      _isLoadingUnreadCount = true;
      _currentPage = page;
    });
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

  IconData _getIconForType() {
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Thông báo ($_unreadCount chưa đọc)",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 36),
                        onPressed: _isLoading ? null : () => _fetchNotifications(page: _currentPage),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterTab(
                          label: 'Chưa đọc',
                          isSelected: _filterType == 'Chưa đọc',
                          onTap: () {
                            setState(() {
                              _filterType = 'Chưa đọc';
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        FilterTab(
                          label: 'Đã đọc',
                          isSelected: _filterType == 'Đã đọc',
                          onTap: () {
                            setState(() {
                              _filterType = 'Đã đọc';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocConsumer<NotificationBloc, NotificationState>(
                    listener: (context, state) {
                      if (state is NotificationError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.message.contains('Failed to fetch')
                                  ? 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại.'
                                  : state.message,
                            ),
                            action: SnackBarAction(
                              label: 'Thử lại',
                              onPressed: () => _fetchNotifications(page: _currentPage),
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
                      } else if (state is PublicNotificationsLoaded) {
                        // No longer used
                      } else if (state is UnreadNotificationsCountLoaded) {
                        setState(() {
                          _unreadCount = state.count;
                          _isLoadingUnreadCount = false;
                          _updateLoadingState();
                        });
                      } else if (state is NotificationMarkedAsRead) {
                        _fetchNotifications(page: _currentPage);
                      } else if (state is AllNotificationsMarkedAsRead) {
                        _fetchNotifications(page: _currentPage);
                      } else if (state is NotificationDeleted) {
                        _fetchNotifications(page: _currentPage);
                      }
                    },
                    builder: (context, state) {
                      List<Notification> notifications = [];
                      if (_filterType == 'Chưa đọc') {
                        notifications = _personalNotifications
                            .where((n) => !n.isRead)
                            .toList();
                      } else if (_filterType == 'Đã đọc') {
                        notifications = _personalNotifications
                            .where((n) => n.isRead)
                            .toList();
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

                      if (_isLoading && _isInitialLoad) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (notifications.isEmpty && state is NotificationError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Không thể tải thông báo'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _fetchNotifications(page: _currentPage),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (notifications.isEmpty) {
                        return const Center(child: Text('Không tìm thấy thông báo'));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: Slidable(
                                    key: Key(notification.notificationId.toString()),
                                    endActionPane: ActionPane(
                                      motion: const BehindMotion(),
                                      extentRatio: 0.4,
                                      children: [
                                        if (!notification.isRead)
                                          Builder(
                                            builder: (cont) {
                                              return Container(
                                                margin: const EdgeInsets.only(left: 4.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Slidable.of(cont)!.close();
                                                    context.read<NotificationBloc>().add(
                                                          MarkNotificationAsReadEvent(
                                                            notificationId: notification.notificationId!,
                                                          ),
                                                        );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const CircleBorder(),
                                                    backgroundColor: Colors.blue,
                                                    padding: const EdgeInsets.all(10),
                                                    minimumSize: const Size(40, 40),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        Builder(
                                          builder: (cont) {
                                            return Container(
                                              margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Slidable.of(cont)!.close();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Xác nhận xóa'),
                                                      content: const Text('Bạn có chắc muốn xóa thông báo này?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Hủy'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            context.read<NotificationBloc>().add(
                                                                  DeleteNotificationEvent(
                                                                    notificationId: notification.notificationId!,
                                                                  ),
                                                                );
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('Xóa'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: const CircleBorder(),
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets.all(10),
                                                  minimumSize: const Size(40, 40),
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: notification.isRead
                                            ? Colors.white
                                            : Colors.lightBlueAccent[50],
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
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
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getIconForType(),
                                                    size: 30,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          notification.title ?? 'Untitled',
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
                                                          'Thông báo',
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
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_totalItems > _limit)
                            PaginationControls(
                              currentPage: _currentPage,
                              totalItems: _totalItems,
                              limit: _limit,
                              onPageChanged: (page) {
                                _fetchNotifications(page: page);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading && !_isInitialLoad)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

