import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';

sealed class BudgetState extends Equatable {
  final List<Budget> budgets;

  const BudgetState({this.budgets = const []});

  @override
  List<Object?> get props => [budgets];
}

final class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

final class BudgetLoading extends BudgetState {
  const BudgetLoading({super.budgets});
}

final class BudgetLoaded extends BudgetState {
  const BudgetLoaded({required super.budgets});
}

final class BudgetDetailLoaded extends BudgetState {
  final Budget detail;

  const BudgetDetailLoaded({required super.budgets, required this.detail});

  @override
  List<Object?> get props => [budgets, detail];
}

final class BudgetSuccess extends BudgetState {
  final String message;
  final Budget? budget;

  const BudgetSuccess({
    required super.budgets,
    required this.message,
    this.budget,
  });

  @override
  List<Object?> get props => [budgets, message, budget];
}

final class BudgetError extends BudgetState {
  final String message;

  const BudgetError({
    required super.budgets,
    required this.message,
  });

  @override
  List<Object?> get props => [budgets, message];
}
