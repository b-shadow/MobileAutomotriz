import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const BudgetRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Budget>>> getBudgets() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getBudgets();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Budget>> getBudgetDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getBudgetDetail(id);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Budget>> createBudget({
    required String citaId,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'cita_id': citaId,
        'descuento': descuento,
      };
      if (observaciones != null) body['observaciones'] = observaciones;
      if (detalles != null) body['detalles'] = detalles;

      final data = await remoteDataSource.createBudget(body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Budget>> updateBudget({
    required String id,
    required double descuento,
    String? observaciones,
    List<Map<String, dynamic>>? detalles,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'descuento': descuento,
      };
      if (observaciones != null) body['observaciones'] = observaciones;
      if (detalles != null) body['detalles'] = detalles;

      final data = await remoteDataSource.updateBudget(id, body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Budget>> changeStatus({
    required String id,
    required String action,
    String? motivo,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.changeStatus(id, action, motivo: motivo);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
