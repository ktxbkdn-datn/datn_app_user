import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FcmRepository {
  Future<String?> getFcmToken();
  Future<void> sendFcmToken(String token, String jwtToken);
  Future<void> initLocalNotifications();
  Future<void> showLocalNotification(RemoteMessage message);
}