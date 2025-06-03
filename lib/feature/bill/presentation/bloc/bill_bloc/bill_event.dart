import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBillDetailEvent extends BillEvent {
  final String billMonth;
  final Map<String, Map<String, double>> readings;

  const SubmitBillDetailEvent({
    required this.billMonth,
    required this.readings,
  });

  @override
  List<Object?> get props => [billMonth, readings];
}

class GetMyBillDetailsEvent extends BillEvent {
  const GetMyBillDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetMyBillsEvent extends BillEvent {
  final int page;
  final int limit;
  final String? billMonth;
  final String? paymentStatus;

  const GetMyBillsEvent({
    this.page = 1,
    this.limit = 10,
    this.billMonth,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [page, limit, billMonth, paymentStatus];
}

class ResetBillStateEvent extends BillEvent {
  const ResetBillStateEvent();

  @override
  List<Object?> get props => [];
}