import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class RegisterBudgetPayment {
  final BudgetRepository repository;
  RegisterBudgetPayment(this.repository);

  Future<Result<Budget>> call({
    required String id,
    required double monto,
    required String metodoPago,
  }) =>
      repository.registerPayment(id: id, monto: monto, metodoPago: metodoPago);
}
