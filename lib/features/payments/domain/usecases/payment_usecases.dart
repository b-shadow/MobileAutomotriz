import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';
import 'package:mobile1_app/features/payments/domain/repositories/payments_repository.dart';

class GetPayments {
  final PaymentsRepository repository;
  GetPayments(this.repository);

  Future<Result<List<PaymentTallerEntity>>> call(NoParams params) =>
      repository.getPayments();
}

class CreatePaymentTallerUseCase {
  final PaymentsRepository repository;
  CreatePaymentTallerUseCase(this.repository);

  Future<Result<PaymentTallerEntity>> call(Map<String, dynamic> data) =>
      repository.createPayment(data);
}

class MarkPaymentReceivedUseCase {
  final PaymentsRepository repository;
  MarkPaymentReceivedUseCase(this.repository);

  Future<Result<PaymentTallerEntity>> call(String paymentId) =>
      repository.markReceived(paymentId);
}
