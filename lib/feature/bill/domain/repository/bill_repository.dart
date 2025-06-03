import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../data/datasource/bill_datasource.dart';
import '../../domain/entity/bill_entities.dart';

abstract class BillRepository {
  Future<Either<Failure, String>> submitBillDetail({
    required String billMonth,
    required Map<String, Map<String, double>> readings,
  });

  Future<Either<Failure, List<BillDetail>>> getMyBillDetails();

  Future<Either<Failure, (List<MonthlyBill>, int)>> getMyBills({
    int page = 1,
    int limit = 10,
    String? billMonth,
    String? paymentStatus,
  });
}