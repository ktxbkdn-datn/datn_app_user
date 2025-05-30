import 'dart:convert';
import 'package:datn_app/src/core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../src/core/di/injection.dart';

abstract class FcmDataSource {
  Future<String?> getFcmToken();
  Future<void> sendFcmTokenToBackend(String token, String jwtToken);
  Future<void> initLocalNotifications();
  Future<void> showLocalNotification(RemoteMessage message);
}

class FcmDataSourceImpl implements FcmDataSource {
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin localNotifications;
  final ApiService apiService = getIt<ApiService>();

  FcmDataSourceImpl({
    required this.firebaseMessaging,
    required this.localNotifications,
  });

  @override
  Future<String?> getFcmToken() async {
    try {
      final token = await firebaseMessaging.getToken();
      print('FCM token retrieved: $token');
      return token;
    } catch (e) {
      print('Error retrieving FCM token: $e');
      throw Exception('Failed to retrieve FCM token: $e');
    }
  }

  @override
  Future<void> sendFcmTokenToBackend(String token, String jwtToken) async {
    try {
      print('Sending FCM token to backend: $token with JWT: $jwtToken');
      await apiService.updateFcmToken(token, jwtToken);
      print('FCM token sent successfully');
    } catch (e) {
      print('Error sending FCM token to backend: $e');
      throw Exception('Failed to send FCM token: $e');
    }
  }

  @override
  Future<void> initLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Local notification response: $response');
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'dormitory_channel',
        'Dormitory Notifications',
        description: 'Notifications for Dormitory App',
        importance: Importance.max,
      );
      await localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  @override
  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      print('Showing local notification: ${message.data}');
      print('Notification title: ${message.notification?.title}');
      print('Notification body: ${message.notification?.body}');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'dormitory_channel',
        'Dormitory Notifications',
        channelDescription: 'Notifications for Dormitory App',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'app_icon',
        channelShowBadge: true,
        playSound: true,
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
      await localNotifications.show(
        message.data['notification_id'] != null ? int.parse(message.data['notification_id']) : 0,
        message.notification?.title ?? 'Thông báo mới',
        message.notification?.body ?? 'Bạn có thông báo mới',
        platformDetails,
        payload: jsonEncode(message.data),
      );
      print('Local notification shown: ${message.notification?.title ?? 'Thông báo mới'}');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }
}