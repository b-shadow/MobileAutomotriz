import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class ConfirmPayment
    implements UseCase<Map<String, dynamic>, ConfirmPaymentParams> {
  final CompanyRepository repository;

  const ConfirmPayment(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(
      ConfirmPaymentParams params) async {
    return await repository.confirmPayment(
      paymentIntentId: params.paymentIntentId,
      planId: params.planId,
      accion: params.accion,
    );
  }
}

class ConfirmPaymentParams extends Equatable {
  final String paymentIntentId;
  final String planId;
  final String accion; // 'cambiar' or 'renovar'

  const ConfirmPaymentParams({
    required this.paymentIntentId,
    required this.planId,
    required this.accion,
  });

  @override
  List<Object?> get props => [paymentIntentId, planId, accion];
}
