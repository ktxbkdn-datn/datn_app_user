import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/contract_entity.dart';
import '../repository/contract_repository.dart';

class GetUserContracts {
  final ContractRepository repository;

  GetUserContracts(this.repository);

  Future<Either<Failure, List<Contract>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getUserContracts(page: page, limit: limit);
  }
}