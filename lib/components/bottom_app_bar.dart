// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/common/widgets/no_spell_check_text.dart';
import 'package:datn_app/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:datn_app/feature/notification/presentation/bloc/notification_event.dart';
import 'package:datn_app/feature/notification/presentation/bloc/notification_state.dart';
import 'package:datn_app/feature/notification/presentation/page/notification_screen.dart';
import 'package:datn_app/feature/notification/presentation/service/fcm_service.dart';
import 'package:datn_app/src/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feature/bill/presentation/pages/payment_page.dart';
import '../feature/profile/presentation/page/setting_page.dart';
import '../feature/report/presentation/page/report_page.dart';
import '../feature/room/presentations/pages/view_room.dart';

class KBottomAppBar extends StatefulWidget {
  const KBottomAppBar({super.key});

  @override
  KBottomAppBarState createState() => KBottomAppBarState();
}

class KBottomAppBarState extends State<KBottomAppBar> {  
  int _currentIndex = 0;
  Timer? _debounce;
  StreamSubscription? _notificationSubscription;

  final List<Widget> _pages = [
    const ViewRoom(showBackButton: false),
    const ReportScreen(),
    const PaymentScreen(),
    const NotificationListScreen(),
    const SettingPage(),
  ];
  @override
  void initState() {
    super.initState();
    
    // Sử dụng addPostFrameCallback để đảm bảo build đã hoàn thành
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Fetch unread notifications count using the safe method
      _safelyProcessNotifications();
      
      // Gửi FCM token - đã có kiểm tra mounted trong phương thức
      _sendFcmToken();
    });
    
    // Lắng nghe thông báo mới với debounce
    try {
      _notificationSubscription = context.read<NotificationBloc>().stream.listen((state) {
        if (!mounted) return; // Skip if widget is no longer mounted
        
        if (state is NewFcmNotification) {
          print('New notification received: ${state.message.data}, refreshing unread count');
          _debounceFetchCount();
        }
      });
    } catch (e) {
      print('Error setting up notification listener: $e');
    }
  }
  /// Method with additional error handling for sending FCM token
  Future<void> _sendFcmToken() async {
    // Kiểm tra mounted ngay đầu hàm để tránh thao tác với widget đã bị huỷ
    if (!mounted) return;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');
      if (accessToken != null) {
        print('Found access token in SharedPreferences: $accessToken');
        try {
          final fcmService = getIt<FcmService>();
          await fcmService.sendToken(accessToken);
          print('FCM token send initiated with JWT: $accessToken');
        } catch (e) {
          print('Error with FCM service: $e');
          // Deliberately swallow the exception to prevent crashes
        }
      } else {
        print('No accessToken found in SharedPreferences');
        // Show a snackbar only if mounted and not in a crash situation
        if (mounted) {
          try {
            Get.snackbar(
              'Lỗi', 
              'Không tìm thấy access token', 
              snackPosition: SnackPosition.TOP, 
              duration: const Duration(seconds: 3)
            );
          } catch (e) {
            print('Error showing snackbar: $e');
          }
        }
      }
    } catch (e) {
      print('Error in _sendFcmToken: $e');
      // Deliberately swallow the exception
    }
  }
  // Debounce để tránh fetch quá thường xuyên
  void _debounceFetchCount() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _safelyProcessNotifications();
    });
  }
  /// Safety mechanism to prevent crashes during notification processing
  void _safelyProcessNotifications() {
    try {
      if (mounted) {
        context.read<NotificationBloc>().add(const FetchUnreadNotificationsCountEvent());
      }
    } catch (e) {
      print('Error safely processing notifications: $e');
      // Don't let exceptions bubble up
    }
  }

  @override
  void dispose() {
    // Hủy timer để tránh callback sau khi widget unmounted
    _debounce?.cancel();
    // Hủy subscription để tránh callback sau khi widget unmounted
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          int unreadCount = 0;
          
          // Handle notification count with error protection
          try {
            if (state is UnreadNotificationsCountLoaded) {
              unreadCount = state.count;
              print('Unread count updated: $unreadCount');
            }
          } catch (e) {
            print('Error handling notification count: $e');
            // Keep unreadCount as 0 if there's any error
          }
          
          // Ensure count is never negative
          unreadCount = unreadCount < 0 ? 0 : unreadCount;

          final navBarItems = [
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.home_outline),
              title: NoSpellCheckText(
                text: "Trang chủ",
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 14),
                ),
              ),
              selectedColor: Colors.deepPurple[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.open),
              title: NoSpellCheckText(
                text: "Báo cáo",
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 14),
                ),
              ),
              selectedColor: Colors.pinkAccent[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.cash_outline),
              title: NoSpellCheckText(
                text: "Hoá đơn",
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 14),
                ),
              ),
              selectedColor: Colors.orangeAccent[400],
            ),
            SalomonBottomBarItem(
              icon: Stack(
                children: [
                  const Icon(Ionicons.notifications),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: BoxConstraints(
                          minWidth: ResponsiveUtils.sp(context, 16),
                          minHeight: ResponsiveUtils.sp(context, 16),
                        ),
                        child: Center(
                          child: NoSpellCheckText(
                            text: unreadCount > 99 ? "99+" : unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.sp(context, 9),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: NoSpellCheckText(
                text: "Thông báo",
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 14),
                ),
              ),
              selectedColor: Colors.blueAccent[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.settings),
              title: NoSpellCheckText(
                text: "Cài đặt",
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 14),
                ),
              ),
              selectedColor: Colors.tealAccent[400],
            ),
          ];

          // Đảm bảo height của bottom navigation bar phù hợp với các thiết bị
          final bottomNavHeight = ResponsiveUtils.isTablet(context) 
              ? kBottomNavigationBarHeight * 1.2 
              : kBottomNavigationBarHeight;

          return SizedBox(
            height: bottomNavHeight,
            child: SalomonBottomBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              items: navBarItems,
              selectedItemColor: const Color(0xff6200ee),
              unselectedItemColor: const Color(0xff757575),
              onTap: (index) {
                if (index >= 0 && index < _pages.length) {
                  setState(() {
                    _currentIndex = index;
                  });
                } else {
                  debugPrint('Invalid index: $index');
                }
              },
            ),
          );
        },
      ),
    );
  }
}