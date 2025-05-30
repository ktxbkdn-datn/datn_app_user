import 'package:equatable/equatable.dart';
import '../../domain/entity/payment_transaction_entity.dart';

abstract class PaymentTransactionState extends Equatable {
  const PaymentTransactionState();

  @override
  List<Object?> get props => [];
}

class PaymentTransactionInitial extends PaymentTransactionState {}

class PaymentTransactionLoading extends PaymentTransactionState {}

class PaymentTransactionLoaded extends PaymentTransactionState {
  final PaymentTransaction? selectedTransaction;
  final List<PaymentTransaction> transactions;

  const PaymentTransactionLoaded({
    this.selectedTransaction,
    this.transactions = const [],
  });

  PaymentTransactionLoaded copyWith({
    PaymentTransaction? selectedTransaction,
    List<PaymentTransaction>? transactions,
  }) {
    return PaymentTransactionLoaded(
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [selectedTransaction, transactions];
}

class PaymentTransactionEmpty extends PaymentTransactionState {
  final String message;

  const PaymentTransactionEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentTransactionError extends PaymentTransactionState {
  final String message;

  const PaymentTransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}