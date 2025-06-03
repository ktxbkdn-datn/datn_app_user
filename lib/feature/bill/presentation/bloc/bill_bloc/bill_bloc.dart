import 'package:datn_app/feature/bill/domain/entity/bill_entities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../src/core/error/failures.dart';
import '../../../domain/repository/bill_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository billRepository;
  final Map<int, List<MonthlyBill>> _billsCache = {};
  static const int _cacheLimit = 5;

  BillBloc({required this.billRepository}) : super(BillInitial()) {
    on<SubmitBillDetailEvent>(_onSubmitBillDetail);
    on<GetMyBillDetailsEvent>(_onGetMyBillDetails);
    on<GetMyBillsEvent>(_onGetMyBills);
    on<ResetBillStateEvent>(_onResetBillState);
  }

  void _manageCache(int page, List<MonthlyBill> bills) {
    _billsCache[page] = bills;
    if (_billsCache.length > _cacheLimit) {
      final oldestPage = _billsCache.keys.reduce((a, b) => a < b ? a : b);
      _billsCache.remove(oldestPage);
    }
  }

  void _clearCache() {
    _billsCache.clear();
  }

  Future<void> _onSubmitBillDetail(
      SubmitBillDetailEvent event,
      Emitter<BillState> emit,
      ) async {
    emit(BillLoading());
    print('Submitting bill detail: billMonth=${event.billMonth}, readings=${event.readings}');
    final result = await billRepository.submitBillDetail(
      billMonth: event.billMonth,
      readings: event.readings,
    );
    emit(
      result.fold(
        (failure) {
          print('Bill submission failed: ${failure.message}');
          if (failure is NetworkFailure) {
            return BillError(
              message: 'Không có kết nối mạng: ${failure.message}',
            );
          }
          if (failure is ServerFailure && failure.message.contains('Phản hồi từ server không đúng định dạng')) {
            return BillError(
              message: 'Lỗi hệ thống: Dữ liệu trả về không đúng định dạng. Vui lòng thử lại.',
            );
          }
          return BillError(message: failure.message);
        },
        (message) {
          print('Bill submission successful: $message');
          _clearCache();
          add(const GetMyBillsEvent(
            page: 1,
            limit: 10,
            paymentStatus: 'PAID',
          ));
          return BillLoaded(
            billDetails: const [],
            bills: const [],
            billDetailsPagination: const PaginationInfo(
              currentPage: 1,
              totalPages: 1,
              totalItems: 0,
            ),
            billsPagination: const PaginationInfo(
              currentPage: 1,
              totalPages: 1,
              totalItems: 0,
            ),
          );
        },
      ),
    );
  }

  Future<void> _onGetMyBillDetails(
      GetMyBillDetailsEvent event,
      Emitter<BillState> emit,
      ) async {
    emit(BillLoading());
    final result = await billRepository.getMyBillDetails();
    emit(
      result.fold(
        (failure) {
          print('Get bill details failed: ${failure.message}');
          if (failure is NetworkFailure) {
            return BillError(
              message: 'Không có kết nối mạng: ${failure.message}',
            );
          }
          return BillError(message: failure.message);
        },
        (billDetails) {
          print('Get bill details successful: ${billDetails.length} details');
          if (billDetails.isEmpty) {
            return const BillEmpty(message: 'Không có chi tiết hóa đơn nào');
          }
          if (state is BillLoaded) {
            final currentState = state as BillLoaded;
            return currentState.copyWith(
              billDetails: billDetails,
              billDetailsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
                totalItems: 0,
              ),
            );
          } else {
            return BillLoaded(
              billDetails: billDetails,
              bills: const [],
              billDetailsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
                totalItems: 0,
              ),
              billsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
                totalItems: 0,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onGetMyBills(
      GetMyBillsEvent event,
      Emitter<BillState> emit,
      ) async {
    if (_billsCache.containsKey(event.page)) {
      print('Fetching bills from cache: page=${event.page}');
      final bills = _billsCache[event.page]!;
      emit(
        BillLoaded(
          billDetails: const [],
          bills: bills,
          billDetailsPagination: const PaginationInfo(
            currentPage: 1,
            totalPages: 1,
            totalItems: 0,
          ),
          billsPagination: PaginationInfo(
            currentPage: event.page,
            totalPages: (bills.length / event.limit).ceil(),
            totalItems: bills.length,
          ),
        ),
      );
      return;
    }

    emit(BillLoading());
    print('Fetching bills: page=${event.page}, limit=${event.limit}, billMonth=${event.billMonth}, paymentStatus=${event.paymentStatus}');
    final result = await billRepository.getMyBills(
      page: event.page,
      limit: event.limit,
      billMonth: event.billMonth,
      paymentStatus: event.paymentStatus,
    );
    emit(
      result.fold(
        (failure) {
          print('Get bills failed: ${failure.message}');
          if (failure is NetworkFailure) {
            return BillError(
              message: 'Không có kết nối mạng: ${failure.message}',
            );
          }
          if (failure is ServerFailure && failure.message.contains('Không tìm thấy hóa đơn nào')) {
            return BillEmpty(message: 'Không tìm thấy hóa đơn nào');
          }
          return BillError(message: failure.message);
        },
        (data) {
          final bills = data.$1;
          final totalItems = data.$2;
          print('Get bills successful: ${bills.length} bills, totalItems=$totalItems');
          if (bills.isEmpty) {
            return const BillEmpty(
              message: 'Không tìm thấy hóa đơn nào',
            );
          }
          _manageCache(event.page, bills);
          final totalPages = (totalItems / event.limit).ceil();
          if (state is BillLoaded) {
            final currentState = state as BillLoaded;
            return currentState.copyWith(
              bills: bills,
              billsPagination: PaginationInfo(
                currentPage: event.page,
                totalPages: totalPages,
                totalItems: totalItems,
              ),
            );
          } else {
            return BillLoaded(
              billDetails: const [],
              bills: bills,
              billDetailsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
                totalItems: 0,
              ),
              billsPagination: PaginationInfo(
                currentPage: event.page,
                totalPages: totalPages,
                totalItems: totalItems,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onResetBillState(
      ResetBillStateEvent event,
      Emitter<BillState> emit,
      ) async {
    print('Resetting BillBloc state');
    _clearCache();
    emit(BillInitial());
  }
}