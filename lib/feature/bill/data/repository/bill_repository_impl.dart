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
  Future<Either<Failure, (List<MonthlyBill>, int)>> getMyBills({
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
    return result.map((data) {
      final bills = data.$1.map((model) => model.toEntity()).toList();
      final totalItems = data.$2;
      return (bills, totalItems);
    });
  }   @override
  Future<Either<Failure, List<BillDetail>>> getRoomBillDetails({
    required int roomId,
    required int year,
    required int serviceId, // thêm serviceId
  }) async {
    print('\n=== BILL REPOSITORY: GET ROOM BILL DETAILS ===');
    print('Calling remoteDataSource.getRoomBillDetails with:');
    print('roomId: $roomId');
    print('year: $year');
    print('serviceId: $serviceId');
    
    final result = await remoteDataSource.getRoomBillDetails(
      roomId: roomId,
      year: year,
      serviceId: serviceId, // truyền serviceId
    );
    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }
}