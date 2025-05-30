import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/usecase/fcm_usecase.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../page/notification_detail_screen.dart';

class FcmService {
  final GetFcmToken getFcmToken;
  final SendFcmToken sendFcmToken;
  final NotificationBloc notificationBloc;
  GlobalKey<NavigatorState> navigatorKey;

  FcmService({
    required this.getFcmToken,
    required this.sendFcmToken,
    required this.notificationBloc,
    required this.navigatorKey,
  });

  Future<void> init(String? jwtToken) async {
    print('Initializing FcmService with JWT: $jwtToken');

    // Yêu cầu quyền thông báo
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('Notification permission status: ${settings.authorizationStatus}');
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('Notification permission not granted. FCM may not work.');
        Get.snackbar(
          'Cảnh báo',
          'Quyền thông báo chưa được cấp. Vui lòng cấp quyền để nhận thông báo.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể yêu cầu quyền thông báo: $e',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    }

    // Khởi tạo local notifications
    try {
      await notificationBloc.fcmRepository.initLocalNotifications();
      print('Local notifications initialized');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }

    // Gửi token nếu có JWT
    if (jwtToken != null) {
      await sendToken(jwtToken);
    }

    // Lắng nghe token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      if (jwtToken != null) {
        await sendToken(jwtToken);
      }
      print('FCM Token refreshed and sent to backend: $newToken');
    });

    // Xử lý thông báo khi ứng dụng ở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground: ${message.data}');
      await notificationBloc.fcmRepository.showLocalNotification(message);
      notificationBloc.add(NewFcmNotificationReceived(message));
    });

    // Xử lý thông báo khi ứng dụng ở background và người dùng nhấp
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked from background: ${message.data}');
      _navigateToDetail(message);
    });

    // Xử lý thông báo khi ứng dụng terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state: ${initialMessage.data}');
      _navigateToDetail(initialMessage);
    }
  }

  Future<void> sendToken(String jwtToken) async {
    print('Attempting to send FCM token with JWT: $jwtToken');

    String? token;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('Attempt $attempt to retrieve FCM token...');
        token = await getFcmToken();
        print('Retrieved FCM token: $token');
        if (token != null) break;
        print('FCM token is null on attempt $attempt. Retrying in 5 seconds...');
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error getting FCM token on attempt $attempt: $e');
        if (attempt == 3) {
          Get.snackbar('Lỗi', 'Không thể lấy FCM token sau 3 lần thử: $e', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 5));
        }
        await Future.delayed(Duration(seconds: 5));
      }
    }

    if (token != null) {
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('Attempt $attempt to send FCM token to backend: $token');
          await sendFcmToken(token, jwtToken);
          print('FCM Token sent successfully: $token');
          break;
        } catch (e) {
          print('Error sending FCM token on attempt $attempt: $e');
          if (attempt == 3) {
            Get.snackbar('Lỗi', 'Không thể gửi FCM token lên backend sau 3 lần thử: $e', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 5));
          }
          await Future.delayed(Duration(seconds: 5));
        }
      }
    } else {
      print('Failed to retrieve FCM token after all attempts');
      Get.snackbar('Lỗi', 'Không thể lấy FCM token để gửi lên backend.', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 5));
    }
  }

  void updateNavigatorKey(GlobalKey<NavigatorState> newKey) {
    print('Updating navigatorKey in FcmService');
    navigatorKey = newKey;
  }

  void _navigateToDetail(RemoteMessage message) {
    print('Navigating to detail screen for message: ${message.data}');
    final notificationId = message.data['notification_id'] ?? '';
    final recipientId = int.tryParse(message.data['notification_id'] ?? '');
    final title = message.notification?.title ?? 'Thông báo';
    final body = message.notification?.body ?? '';

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(
          title: title,
          message: body,
          timestamp: DateTime.now().toIso8601String(),
          notificationId: int.tryParse(notificationId) ?? 0,
          recipientId: recipientId,
        ),
      ),
    );

    notificationBloc.add(const FetchUserNotificationsEvent(page: 1, limit: 50, isRead: null));
    notificationBloc.add(const FetchUnreadNotificationsCountEvent());
  }
}