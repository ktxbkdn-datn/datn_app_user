import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/bill_entities.dart';
import '../repository/bill_repository.dart';

class SubmitBillDetail {
  final BillRepository repository;

  SubmitBillDetail(this.repository);

  Future<Either<Failure, String>> call({
    required String billMonth,
    required Map<String, Map<String, double>> readings,
  }) async {
    return await repository.submitBillDetail(
      billMonth: billMonth,
      readings: readings,
    );
  }
}

class GetMyBillDetails {
  final BillRepository repository;

  GetMyBillDetails(this.repository);

  Future<Either<Failure, List<BillDetail>>> call() async {
    return await repository.getMyBillDetails();
  }
}

class GetMyBills {
  final BillRepository repository;

  GetMyBills(this.repository);

  Future<Either<Failure, (List<MonthlyBill>, int)>> call({
    int page = 1,
    int limit = 10,
    String? billMonth,
    String? paymentStatus,
  }) async {
    return await repository.getMyBills(
      page: page,
      limit: limit,
      billMonth: billMonth,
      paymentStatus: paymentStatus,
    );
  }
}

class GetRoomBillDetails {
  final BillRepository repository;

  GetRoomBillDetails(this.repository);

  Future<Either<Failure, List<BillDetail>>> call({
    required int roomId,
    required int year,
    required int serviceId, // thêm serviceId
  }) async {
    return await repository.getRoomBillDetails(
      roomId: roomId,
      year: year,
      serviceId: serviceId, // truyền serviceId
    );
  }
}