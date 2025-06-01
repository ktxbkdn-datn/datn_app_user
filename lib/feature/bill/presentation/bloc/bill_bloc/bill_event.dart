import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện gửi chỉ số dịch vụ (điện, nước, v.v.) cho một phòng.
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

/// Sự kiện lấy danh sách chi tiết hóa đơn của một phòng.
class GetMyBillDetailsEvent extends BillEvent {
  const GetMyBillDetailsEvent();

  @override
  List<Object> get props => [];
}

/// Sự kiện lấy danh sách hóa đơn của một phòng, hỗ trợ phân trang và lọc theo tháng.
class GetMyBillsEvent extends BillEvent {
  final int page;
  final int limit;
  final String? billMonth;
  final String? paymentStatus; // Thêm payment_status

  const GetMyBillsEvent({
    this.page = 1,
    this.limit = 10,
    this.billMonth,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [page, limit, billMonth, paymentStatus];
}

/// Sự kiện reset trạng thái của BLoC về trạng thái ban đầu.
class ResetBillStateEvent extends BillEvent {
  const ResetBillStateEvent();

  @override
  List<Object?> get props => [];
}