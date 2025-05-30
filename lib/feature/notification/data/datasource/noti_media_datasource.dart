import 'package:http/http.dart' as http;
import '../../../../src/core/network/api_client.dart';
import '../model/notification_media_model.dart';

abstract class NotificationMediaRemoteDataSource {
  Future<List<NotificationMediaModel>> getNotificationMedia({
    required int notificationId,
    String? fileType,
  });
}

class NotificationMediaRemoteDataSourceImpl implements NotificationMediaRemoteDataSource {
  final ApiService apiService;

  NotificationMediaRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<NotificationMediaModel>> getNotificationMedia({
    required int notificationId,
    String? fileType,
  }) async {
    final queryParams = {
      if (fileType != null) 'file_type': fileType,
    };
    final response = await apiService.get(
      '/notifications/$notificationId/media',
      queryParams: queryParams,
    );
    return (response['media'] as List)
        .map((json) => NotificationMediaModel.fromJson(json))
        .toList();
  }
}