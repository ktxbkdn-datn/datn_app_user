import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entities/contract_entity.dart';

abstract class ContractRepository {
  Future<Either<Failure, List<Contract>>> getUserContracts({
    int page = 1,
    int limit = 10,
  });
}