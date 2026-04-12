import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class CreatePaymentIntent
    implements UseCase<Map<String, dynamic>, CreatePaymentIntentParams> {
  final CompanyRepository repository;

  const CreatePaymentIntent(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(
      CreatePaymentIntentParams params) async {
    return await repository.createPaymentIntent(
      planId: params.planId,
      accion: params.accion,
    );
  }
}

class CreatePaymentIntentParams extends Equatable {
  final String planId;
  final String accion; // 'cambiar' or 'renovar'

  const CreatePaymentIntentParams({
    required this.planId,
    required this.accion,
  });

  @override
  List<Object?> get props => [planId, accion];
}
