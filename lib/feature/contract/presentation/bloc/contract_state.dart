import 'package:equatable/equatable.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {
  final bool isLoading;

  const ContractLoading({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class ContractListLoaded extends ContractState {
  final List<Contract> contracts;

  const ContractListLoaded({required this.contracts});

  @override
  List<Object?> get props => [contracts];
}

class ContractError extends ContractState {
  final Failure failure;
  final String errorMessage;

  const ContractError({required this.failure, required this.errorMessage});

  @override
  List<Object?> get props => [failure, errorMessage];
}