import 'package:equatable/equatable.dart';
import '../../domain/entity/bill_entities.dart';

/// Thông tin phân trang cho danh sách hóa đơn hoặc chi tiết hóa đơn.
class PaginationInfo extends Equatable {
  final int currentPage;
  final int totalPages;

  const PaginationInfo({required this.currentPage, required this.totalPages});

  @override
  List<Object> get props => [currentPage, totalPages];
}

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu của BLoC.
class BillInitial extends BillState {}

/// Trạng thái khi đang tải dữ liệu.
class BillLoading extends BillState {}

/// Trạng thái khi dữ liệu đã được tải thành công.
class BillLoaded extends BillState {
  final List<BillDetail> billDetails;
  final List<MonthlyBill> bills;
  final PaginationInfo billDetailsPagination;
  final PaginationInfo billsPagination;

  const BillLoaded({
    this.billDetails = const [],
    this.bills = const [],
    required this.billDetailsPagination,
    required this.billsPagination,
  });

  BillLoaded copyWith({
    List<BillDetail>? billDetails,
    List<MonthlyBill>? bills,
    PaginationInfo? billDetailsPagination,
    PaginationInfo? billsPagination,
  }) {
    return BillLoaded(
      billDetails: billDetails ?? this.billDetails,
      bills: bills ?? this.bills,
      billDetailsPagination:
          billDetailsPagination ?? this.billDetailsPagination,
      billsPagination: billsPagination ?? this.billsPagination,
    );
  }

  @override
  List<Object?> get props => [
    billDetails,
    bills,
    billDetailsPagination,
    billsPagination,
  ];
}

/// Trạng thái khi không có dữ liệu (danh sách rỗng).
class BillEmpty extends BillState {
  final String message;

  const BillEmpty({required this.message});

  @override
  List<Object> get props => [message];
}

/// Trạng thái khi xảy ra lỗi.
class BillError extends BillState {
  final String message;

  const BillError({required this.message});

  @override
  List<Object> get props => [message];
}
