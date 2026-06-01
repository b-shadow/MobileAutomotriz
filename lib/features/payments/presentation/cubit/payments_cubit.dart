import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';
import 'package:mobile1_app/features/payments/domain/usecases/payment_usecases.dart';
import 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final GetPayments _getPayments;
  final CreatePaymentTallerUseCase _createPayment;
  final MarkPaymentReceivedUseCase _markReceived;

  List<PaymentTallerEntity> _payments = const [];

  PaymentsCubit({
    required GetPayments getPayments,
    required CreatePaymentTallerUseCase createPayment,
    required MarkPaymentReceivedUseCase markReceived,
  })  : _getPayments = getPayments,
        _createPayment = createPayment,
        _markReceived = markReceived,
        super(const PaymentsInitial());

  Future<void> fetchAll() async {
    emit(PaymentsLoading(payments: _payments));
    final result = await _getPayments(const NoParams());
    switch (result) {
      case Success(:final data):
        _payments = data;
        emit(PaymentsLoaded(payments: _payments));
      case Err(:final failure):
        emit(PaymentsError(payments: _payments, message: failure.message));
    }
  }

  Future<void> createPayment(Map<String, dynamic> data) async {
    emit(PaymentsLoading(payments: _payments));
    final result = await _createPayment(data);
    switch (result) {
      case Success(:final data):
        _payments = [data, ..._payments];
        emit(PaymentsSuccess(
          payments: _payments,
          message: 'Pago registrado exitosamente.',
        ));
      case Err(:final failure):
        emit(PaymentsError(payments: _payments, message: failure.message));
    }
  }

  Future<void> markReceived(String paymentId) async {
    emit(PaymentsLoading(payments: _payments));
    final result = await _markReceived(paymentId);
    switch (result) {
      case Success(:final data):
        _payments = _payments
            .map((p) => p.id == data.id ? data : p)
            .toList();
        emit(PaymentsSuccess(
          payments: _payments,
          message: 'Pago marcado como recibido.',
        ));
      case Err(:final failure):
        emit(PaymentsError(payments: _payments, message: failure.message));
    }
  }
}
