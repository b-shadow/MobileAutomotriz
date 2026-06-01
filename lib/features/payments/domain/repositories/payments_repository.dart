import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';

abstract class PaymentsRepository {
  Future<Result<List<PaymentTallerEntity>>> getPayments();
  Future<Result<PaymentTallerEntity>> createPayment(Map<String, dynamic> data);
  Future<Result<PaymentTallerEntity>> markReceived(String paymentId);
}
