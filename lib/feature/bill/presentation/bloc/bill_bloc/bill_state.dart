import 'package:equatable/equatable.dart';
import '../../../domain/entity/bill_entities.dart';

class PaginationInfo extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  @override
  List<Object> get props => [currentPage, totalPages, totalItems];
}

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

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

class BillEmpty extends BillState {
  final String message;

  const BillEmpty({required this.message});

  @override
  List<Object> get props => [message];
}

class BillError extends BillState {
  final String message;

  const BillError({required this.message});

  @override
  List<Object> get props => [message];
}

