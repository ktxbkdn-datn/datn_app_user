import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/service_models.dart';

abstract class ServiceRemoteDataSource {
  Future<Either<Failure, List<ServiceModel>>> getServices({
    int page = 1,
    int limit = 10,
  });
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiService apiService;

  ServiceRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get(
        '/services',
        queryParams: queryParams,
      );
      final services = (response['services'] as List)
          .map((json) => ServiceModel.fromJson(json))
          .toList();
      return Right(services);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ApiException) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Lỗi không xác định: $error');
    }
  }
}