import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';

sealed class PaymentsState extends Equatable {
  final List<PaymentTallerEntity> payments;
  const PaymentsState({this.payments = const []});

  @override
  List<Object?> get props => [payments];
}

final class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

final class PaymentsLoading extends PaymentsState {
  const PaymentsLoading({super.payments});
}

final class PaymentsLoaded extends PaymentsState {
  const PaymentsLoaded({required super.payments});
}

final class PaymentsSuccess extends PaymentsState {
  final String message;
  const PaymentsSuccess({required super.payments, required this.message});

  @override
  List<Object?> get props => [payments, message];
}

final class PaymentsError extends PaymentsState {
  final String message;
  const PaymentsError({required super.payments, required this.message});

  @override
  List<Object?> get props => [payments, message];
}
