import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/usecase/get_user_contract.dart';

import 'contract_event.dart';
import 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final GetUserContracts getUserContracts;
  List<Contract> _contracts = [];

  ContractBloc({
    required this.getUserContracts,
  }) : super(ContractInitial()) {
    on<FetchUserContractsEvent>(_onFetchUserContracts);
  }

  Future<void> _onFetchUserContracts(FetchUserContractsEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await getUserContracts(
      page: event.page,
      limit: event.limit,
    );
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (contracts) {
        _contracts = contracts;
        emit(ContractListLoaded(contracts: contracts));
      },
    );
  }
}