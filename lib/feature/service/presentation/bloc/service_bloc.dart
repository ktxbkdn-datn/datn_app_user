import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/repository/service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    on<FetchServicesEvent>(_onFetchServices);
  }

  Future<void> _onFetchServices(
      FetchServicesEvent event,
      Emitter<ServiceState> emit,
      ) async {
    emit(ServiceLoading());
    final result = await serviceRepository.getServices(
      page: event.page,
      limit: event.limit,
    );
    emit(
      result.fold(
            (failure) {
          if (failure is NetworkFailure) {
            return ServiceError(message: 'Không có kết nối mạng: ${failure.message}');
          }
          return ServiceError(message: failure.message);
        },
            (services) {
          return ServiceLoaded(services: services);
        },
      ),
    );
  }
}