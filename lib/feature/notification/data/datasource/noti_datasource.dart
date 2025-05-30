import 'package:http/http.dart' as http;
import '../../../../src/core/network/api_client.dart';
import '../model/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getUserNotifications({
    required int page,
    required int limit,
    bool? isRead,
  });

  Future<List<NotificationModel>> getPublicNotifications({
    required int page,
    required int limit,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<NotificationModel>> getUserNotifications({
    required int page,
    required int limit,
    bool? isRead,
  }) async {
    print('Calling API: GET /me/notifications');
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (isRead != null) 'is_read': isRead.toString(),
    };
    try {
      final response = await apiService.get(
        '/me/notifications',
        queryParams: queryParams,
      );
      print('API Response: /me/notifications -> $response');
      return (response['personal_notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in getUserNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<NotificationModel>> getPublicNotifications({
    required int page,
    required int limit,
  }) async {
    print('Calling API: GET /public/notifications/general');
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    try {
      final response = await apiService.get(
        '/public/notifications/general',
        queryParams: queryParams,
      );
      print('API Response: /public/notifications/general -> $response');
      return (response['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in getPublicNotifications: $e');
      rethrow;
    }
  }
}