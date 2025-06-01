import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../src/core/error/failures.dart';
import '../../../domain/repository/bill_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository billRepository;

  BillBloc({required this.billRepository}) : super(BillInitial()) {
    on<SubmitBillDetailEvent>(_onSubmitBillDetail);
    on<GetMyBillDetailsEvent>(_onGetMyBillDetails);
    on<GetMyBillsEvent>(_onGetMyBills);
    on<ResetBillStateEvent>(_onResetBillState);
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
          return BillError(message: failure.message); // Pass raw message
        },
            (message) {
          print('Bill submission successful: $message');
          return BillLoaded(
            billDetails: const [],
            bills: const [],
            billDetailsPagination: const PaginationInfo(
              currentPage: 1,
              totalPages: 1,
            ),
            billsPagination: const PaginationInfo(
              currentPage: 1,
              totalPages: 1,
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
              ),
            );
          } else {
            return BillLoaded(
              billDetails: billDetails,
              bills: const [],
              billDetailsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
              ),
              billsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
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
            (bills) {
          print('Get bills successful: ${bills.length} bills');
          if (bills.isEmpty) {
            return const BillEmpty(
              message: 'Không tìm thấy hóa đơn nào',
            );
          }
          if (state is BillLoaded) {
            final currentState = state as BillLoaded;
            return currentState.copyWith(
              bills: bills,
              billsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
              ),
            );
          } else {
            return BillLoaded(
              billDetails: const [],
              bills: bills,
              billDetailsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
              ),
              billsPagination: const PaginationInfo(
                currentPage: 1,
                totalPages: 1,
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
    emit(BillInitial());
  }
}