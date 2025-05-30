// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
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
  _KBottomAppBarState createState() => _KBottomAppBarState();
}

class _KBottomAppBarState extends State<KBottomAppBar> {
  int _currentIndex = 0;
  Timer? _debounce;

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
    // Gọi sự kiện để lấy số lượng thông báo chưa đọc
    try {
      context.read<NotificationBloc>().add(const FetchUnreadNotificationsCountEvent());
    } catch (e) {
      print('Error accessing NotificationBloc in initState: $e');
    }
    // Gửi FCM token
    _sendFcmToken();
    // Lắng nghe thông báo mới với debounce
    context.read<NotificationBloc>().stream.listen((state) {
      if (state is NewFcmNotification) {
        print('New notification received: ${state.message.data}, refreshing unread count');
        _debounceFetchCount();
      }
    });
  }

  // Hàm gửi FCM token
  Future<void> _sendFcmToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');
      if (accessToken != null) {
        print('Found access token in SharedPreferences: $accessToken');
        final fcmService = getIt<FcmService>();
        await fcmService.sendToken(accessToken);
        print('FCM token send initiated with JWT: $accessToken');
      } else {
        print('No accessToken found in SharedPreferences');
        Get.snackbar('Lỗi', 'Không tìm thấy access token', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 3));
      }
    } catch (e) {
      print('Error sending FCM token: $e');
      Get.snackbar('Lỗi', 'Không thể gửi FCM token: $e', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 3));
    }
  }

  // Debounce để tránh fetch quá thường xuyên
  void _debounceFetchCount() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<NotificationBloc>().add(const FetchUnreadNotificationsCountEvent());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          int unreadCount = 0;
          if (state is UnreadNotificationsCountLoaded) {
            unreadCount = state.count;
            print('Unread count updated: $unreadCount');
          }

          final _navBarItems = [
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.home_outline),
              title: const Text("Home"),
              selectedColor: Colors.deepPurple[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.open),
              title: const Text("Report"),
              selectedColor: Colors.pinkAccent[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.cash_outline),
              title: const Text("Bill"),
              selectedColor: Colors.orangeAccent[400],
            ),
            SalomonBottomBarItem(
              icon: Stack(
                children: [
                  const Icon(Ionicons.notifications),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              title: const Text("Notification"),
              selectedColor: Colors.blueAccent[400],
            ),
            SalomonBottomBarItem(
              icon: const Icon(Ionicons.settings),
              title: const Text("Setting"),
              selectedColor: Colors.tealAccent[400],
            ),
          ];

          return SalomonBottomBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            items: _navBarItems,
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
          );
        },
      ),
    );
  }
}