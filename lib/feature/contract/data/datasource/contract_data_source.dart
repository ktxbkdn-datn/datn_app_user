import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<List<ContractModel>> getUserContracts({
    int page = 1,
    int limit = 10,
  });
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final ApiService apiService;

  ContractRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ContractModel>> getUserContracts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiService.get(
        '/me/contracts',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final contractsJson = response['contracts'] as List<dynamic>;
      return contractsJson.map((json) => ContractModel.fromJson(json)).toList();
    } catch (e) {
      if (e is ServerFailure) {
        throw ServerFailure(e.message);
      } else if (e is NetworkFailure) {
        throw NetworkFailure(e.message);
      }
      throw ServerFailure('Không thể lấy hợp đồng: $e');
    }
  }
}