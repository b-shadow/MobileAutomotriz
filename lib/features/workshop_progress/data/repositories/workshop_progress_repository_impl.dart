import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/data/datasources/workshop_progress_remote_data_source.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';
import 'package:mobile1_app/features/workshop_progress/domain/repositories/workshop_progress_repository.dart';

class WorkshopProgressRepositoryImpl implements WorkshopProgressRepository {
  final WorkshopProgressRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const WorkshopProgressRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<WorkOrder>>> getActiveWorkOrders() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getActiveWorkOrders();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrder>> getWorkOrderDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getWorkOrderDetail(id);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrderDetail>> startService(String orderId, String detailId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.startService(orderId, detailId);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrderDetail>> pauseService({
    required String orderId,
    required String detailId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.pauseService(orderId, detailId, reason);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrderDetail>> finishService({
    required String orderId,
    required String detailId,
    required int realTimeMinutes,
    String observations = '',
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.finishService(orderId, detailId, realTimeMinutes, observations);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrderDetail>> markAsUnnecessary({
    required String orderId,
    required String detailId,
    required String reason,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.markAsUnnecessary(orderId, detailId, reason);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkOrder>> finishWorkOrder(String orderId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.finishWorkOrder(orderId);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<ProgressLog>>> getProgressHistory(String orderId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getProgressHistory(orderId);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<String>> addManualProgress({
    required String citaId,
    String? detailId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.addManualProgress(
        citaId: citaId,
        detailId: detailId,
        type: type,
        status: status,
        message: message,
        percentage: percentage,
      );
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<InventoryItem>>> getInventoryItems() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getInventoryItems();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<SparePartRequest>>> getSparePartRequests({String? ordenGlobalId}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getSparePartRequests(ordenGlobalId: ordenGlobalId);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> createSparePartRequest({
    required String citaId,
    required String ordenGlobalId,
    required String motivo,
    required List<SparePartRequestLine> lineas,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.createSparePartRequest(
        citaId: citaId, ordenGlobalId: ordenGlobalId, motivo: motivo, lineas: lineas,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> markSparePartsReceived({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.markSparePartsReceived(solicitudId: solicitudId, detalles: detalles);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
