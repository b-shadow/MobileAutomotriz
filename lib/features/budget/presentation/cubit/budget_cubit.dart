import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/usecases/change_budget_status.dart';
import 'package:mobile1_app/features/budget/domain/usecases/create_budget.dart';
import 'package:mobile1_app/features/budget/domain/usecases/get_budget_detail.dart';
import 'package:mobile1_app/features/budget/domain/usecases/get_budgets.dart';
import 'package:mobile1_app/features/budget/domain/usecases/update_budget.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgets _getBudgets;
  final GetBudgetDetail _getBudgetDetail;
  final CreateBudget _createBudget;
  final UpdateBudget _updateBudget;
  final ChangeBudgetStatus _changeBudgetStatus;

  List<Budget> _budgets = const [];

  BudgetCubit({
    required GetBudgets getBudgets,
    required GetBudgetDetail getBudgetDetail,
    required CreateBudget createBudget,
    required UpdateBudget updateBudget,
    required ChangeBudgetStatus changeBudgetStatus,
  })  : _getBudgets = getBudgets,
        _getBudgetDetail = getBudgetDetail,
        _createBudget = createBudget,
        _updateBudget = updateBudget,
        _changeBudgetStatus = changeBudgetStatus,
        super(const BudgetInitial());

  Future<void> fetchBudgets() async {
    emit(BudgetLoading(budgets: _budgets));
    final result = await _getBudgets(const NoParams());
    switch (result) {
      case Success(:final data):
        _budgets = data;
        emit(BudgetLoaded(budgets: _budgets));
      case Err(:final failure):
        emit(BudgetError(budgets: _budgets, message: failure.message));
    }
  }

  Future<void> fetchBudgetDetail(String id) async {
    emit(BudgetLoading(budgets: _budgets));
    final result = await _getBudgetDetail(id);
    switch (result) {
      case Success(:final data):
        emit(BudgetDetailLoaded(budgets: _budgets, detail: data));
      case Err(:final failure):
        emit(BudgetError(budgets: _budgets, message: failure.message));
    }
  }

  Future<void> createBudget({
    required String citaId,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  }) async {
    emit(BudgetLoading(budgets: _budgets));
    final result = await _createBudget(CreateBudgetParams(
      citaId: citaId,
      descuento: descuento,
      observaciones: observaciones,
      detalles: detalles,
    ));
    switch (result) {
      case Success(:final data):
        _budgets = [data, ..._budgets];
        emit(BudgetSuccess(
          budgets: _budgets,
          message: 'Presupuesto generado con éxito.',
          budget: data,
        ));
      case Err(:final failure):
        emit(BudgetError(budgets: _budgets, message: failure.message));
    }
  }

  Future<void> updateBudget({
    required String id,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  }) async {
    emit(BudgetLoading(budgets: _budgets));
    final result = await _updateBudget(UpdateBudgetParams(
      id: id,
      descuento: descuento,
      observaciones: observaciones,
      detalles: detalles,
    ));
    switch (result) {
      case Success(:final data):
        _updateList(data);
        emit(BudgetSuccess(
          budgets: _budgets,
          message: 'Presupuesto actualizado correctamente.',
          budget: data,
        ));
      case Err(:final failure):
        emit(BudgetError(budgets: _budgets, message: failure.message));
    }
  }

  Future<void> changeStatus({
    required String id,
    required String action,
    String? motivo,
  }) async {
    emit(BudgetLoading(budgets: _budgets));
    final result = await _changeBudgetStatus(id: id, action: action, motivo: motivo);
    switch (result) {
      case Success(:final data):
        _updateList(data);
        String msg = 'Estado actualizado';
        if (action == 'comunicar') msg = 'Presupuesto comunicado al cliente.';
        if (action == 'aprobar') msg = 'Presupuesto aprobado.';
        if (action == 'rechazar') msg = 'Presupuesto rechazado.';
        if (action == 'cerrar') msg = 'Presupuesto cerrado.';
        emit(BudgetSuccess(budgets: _budgets, message: msg, budget: data));
      case Err(:final failure):
        emit(BudgetError(budgets: _budgets, message: failure.message));
    }
  }

  void _updateList(Budget updated) {
    final idx = _budgets.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      final newList = List<Budget>.from(_budgets);
      newList[idx] = updated;
      _budgets = newList;
    }
  }
}
