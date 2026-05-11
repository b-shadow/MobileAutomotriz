import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class UpdateBudgetParams extends Equatable {
  final String id;
  final double descuento;
  final String? observaciones;
  final List<Map<String, dynamic>>? detalles;

  const UpdateBudgetParams({
    required this.id,
    required this.descuento,
    this.observaciones,
    this.detalles,
  });

  @override
  List<Object?> get props => [id, descuento, observaciones, detalles];
}

class UpdateBudget implements UseCase<Budget, UpdateBudgetParams> {
  final BudgetRepository repository;
  UpdateBudget(this.repository);

  @override
  Future<Result<Budget>> call(UpdateBudgetParams params) =>
      repository.updateBudget(
        id: params.id,
        descuento: params.descuento,
        observaciones: params.observaciones,
        detalles: params.detalles,
      );
}
