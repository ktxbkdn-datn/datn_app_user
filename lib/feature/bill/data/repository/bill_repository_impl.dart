import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entity/bill_entities.dart';
import '../../domain/repository/bill_repository.dart';
import '../datasource/bill_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> submitBillDetail({
    required String billMonth,
    required Map<String, Map<String, double>> readings,
  }) async {
    return await remoteDataSource.submitBillDetail(
      billMonth: billMonth,
      readings: readings,
    );
  }

  @override
  Future<Either<Failure, List<BillDetail>>> getMyBillDetails() async {
    final result = await remoteDataSource.getMyBillDetails();
    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<MonthlyBill>>> getMyBills({
    int page = 1,
    int limit = 10,
    String? billMonth,
    String? paymentStatus,
  }) async {
    final result = await remoteDataSource.getMyBills(
      page: page,
      limit: limit,
      billMonth: billMonth,
      paymentStatus: paymentStatus,
    );
    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }
}