import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/repository/fcm_repository.dart';
import '../datasource/fcm_datasource.dart';

class FcmRepositoryImpl implements FcmRepository {
  final FcmDataSource dataSource;

  FcmRepositoryImpl(this.dataSource);

  @override
  Future<String?> getFcmToken() async {
    print('FcmRepository: Getting FCM token');
    final token = await dataSource.getFcmToken();
    print('FcmRepository: Got FCM token: $token');
    return token;
  }

  @override
  Future<void> sendFcmToken(String token, String jwtToken) async {
    print('FcmRepository: Sending FCM token: $token');
    await dataSource.sendFcmTokenToBackend(token, jwtToken);
    print('FcmRepository: FCM token sent successfully');
  }

  @override
  Future<void> initLocalNotifications() async {
    print('FcmRepository: Initializing local notifications');
    await dataSource.initLocalNotifications();
    print('FcmRepository: Local notifications initialized');
  }

  @override
  Future<void> showLocalNotification(RemoteMessage message) async {
    print('FcmRepository: Showing local notification: ${message.data}');
    await dataSource.showLocalNotification(message);
    print('FcmRepository: Local notification shown');
  }
}