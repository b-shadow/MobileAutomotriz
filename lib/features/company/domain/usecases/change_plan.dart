import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class ChangePlan implements UseCase<Map<String, dynamic>, ChangePlanParams> {
  final CompanyRepository repository;

  const ChangePlan(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(ChangePlanParams params) async {
    return await repository.changePlan(params.planId);
  }
}

class ChangePlanParams extends Equatable {
  final String planId;
  const ChangePlanParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}
