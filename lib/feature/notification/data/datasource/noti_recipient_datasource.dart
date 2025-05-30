import 'package:http/http.dart' as http;
import '../../../../src/core/network/api_client.dart';
import '../model/noti_recipient_model.dart';

abstract class NotificationRecipientRemoteDataSource {
  Future<NotificationRecipientModel> markNotificationAsRead(int notificationId);
  Future<void> markAllNotificationsAsRead();
  Future<int> getUnreadNotificationsCount();
  Future<void> deleteNotification(int notificationId); // Thêm phương thức mới
}

class NotificationRecipientRemoteDataSourceImpl implements NotificationRecipientRemoteDataSource {
  final ApiService apiService;

  NotificationRecipientRemoteDataSourceImpl(this.apiService);

  @override
  Future<NotificationRecipientModel> markNotificationAsRead(int notificationId) async {
    print('Calling API: PUT /me/notifications/mark-as-read');
    try {
      final endpoint = '/me/notifications/mark-as-read?notification_id=$notificationId';
      final response = await apiService.put(
        endpoint,
        {},
      );
      print('API Response: $endpoint -> $response');
      return NotificationRecipientModel.fromJson(response);
    } catch (e) {
      print('Error in markNotificationAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    print('Calling API: PUT /me/notifications/mark-all-read');
    try {
      await apiService.put(
        '/me/notifications/mark-all-read',
        {},
      );
      print('API Response: /me/notifications/mark-all-read -> Success');
    } catch (e) {
      print('Error in markAllNotificationsAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    print('Calling API: GET /me/notifications/unread-count');
    try {
      final response = await apiService.get('/me/notifications/unread-count');
      print('API Response: /me/notifications/unread-count -> $response');
      return response['count'] as int;
    } catch (e) {
      print('Error in getUnreadNotificationsCount: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    print('Calling API: DELETE /me/notifications/delete');
    try {
      final endpoint = '/me/notifications/delete?notification_id=$notificationId';
      await apiService.delete(endpoint);
      print('API Response: $endpoint -> Success');
    } catch (e) {
      print('Error in deleteNotification: $e');
      rethrow;
    }
  }
}