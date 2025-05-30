import 'package:equatable/equatable.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserContractsEvent extends ContractEvent {
  final int page;
  final int limit;

  const FetchUserContractsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}