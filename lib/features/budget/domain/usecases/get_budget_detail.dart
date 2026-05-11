import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetDetail implements UseCase<Budget, String> {
  final BudgetRepository repository;
  GetBudgetDetail(this.repository);

  @override
  Future<Result<Budget>> call(String params) =>
      repository.getBudgetDetail(params);
}
