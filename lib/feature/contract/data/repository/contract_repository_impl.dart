import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repository/contract_repository.dart';
import '../datasource/contract_data_source.dart';
import '../models/contract_model.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource remoteDataSource;

  ContractRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Contract>>> getUserContracts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getUserContracts(
        page: page,
        limit: limit,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}