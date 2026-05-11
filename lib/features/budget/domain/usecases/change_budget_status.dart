import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class ChangeBudgetStatus {
  final BudgetRepository repository;
  ChangeBudgetStatus(this.repository);

  Future<Result<Budget>> call({
    required String id,
    required String action,
    String? motivo,
  }) =>
      repository.changeStatus(id: id, action: action, motivo: motivo);
}
