import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class CreateBudgetParams extends Equatable {
  final String citaId;
  final double descuento;
  final String? observaciones;
  final List<Map<String, dynamic>>? detalles;

  const CreateBudgetParams({
    required this.citaId,
    required this.descuento,
    this.observaciones,
    this.detalles,
  });

  @override
  List<Object?> get props => [citaId, descuento, observaciones, detalles];
}

class CreateBudget implements UseCase<Budget, CreateBudgetParams> {
  final BudgetRepository repository;
  CreateBudget(this.repository);

  @override
  Future<Result<Budget>> call(CreateBudgetParams params) =>
      repository.createBudget(
        citaId: params.citaId,
        descuento: params.descuento,
        observaciones: params.observaciones,
        detalles: params.detalles,
      );
}
