import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class GetBudgets implements UseCase<List<Budget>, NoParams> {
  final BudgetRepository repository;
  GetBudgets(this.repository);

  @override
  Future<Result<List<Budget>>> call(NoParams params) =>
      repository.getBudgets();
}
