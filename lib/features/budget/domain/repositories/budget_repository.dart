import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<Result<List<Budget>>> getBudgets();
  
  Future<Result<Budget>> getBudgetDetail(String id);
  
  Future<Result<Budget>> createBudget({
    required String citaId,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  });
  
  Future<Result<Budget>> updateBudget({
    required String id,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  });
  
  Future<Result<Budget>> changeStatus({
    required String id,
    required String action, // comunicar, aprobar, rechazar, ajustar, cerrar
    String? motivo, // Solo para rechazar
  });
}
