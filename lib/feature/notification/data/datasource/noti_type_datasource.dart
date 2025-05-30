import 'package:http/http.dart' as http;
import '../../../../src/core/network/api_client.dart';
import '../model/noti_type_model.dart';

abstract class NotificationTypeRemoteDataSource {
  Future<List<NotificationTypeModel>> getAllNotificationTypes({
    required int page,
    required int limit,
  });
}

class NotificationTypeRemoteDataSourceImpl implements NotificationTypeRemoteDataSource {
  final ApiService apiService;

  NotificationTypeRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<NotificationTypeModel>> getAllNotificationTypes({
    required int page,
    required int limit,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final response = await apiService.get(
      '/notification-types',
      queryParams: queryParams,
    );
    return (response['notification_types'] as List)
        .map((json) => NotificationTypeModel.fromJson(json))
        .toList();
  }
}