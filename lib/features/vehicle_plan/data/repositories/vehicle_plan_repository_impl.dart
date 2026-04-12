import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/vehicle_plan/data/datasources/vehicle_plan_remote_data_source.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class VehiclePlanRepositoryImpl implements VehiclePlanRepository {
  final VehiclePlanRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const VehiclePlanRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Result<List<VehiclePlan>>> getPlans() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getPlans();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlan>> getPlanDetail(String planId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.getPlanDetail(planId));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlan>> updatePlan({required String planId, required Map<String, dynamic> data}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.updatePlan(planId: planId, data: data));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlan>> updatePlanStatus({required String planId, required String estado, String? motivo}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.updatePlanStatus(planId: planId, estado: estado, motivo: motivo));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<VehiclePlanDetail>>> getPlanDetails(String planId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.getPlanDetails(planId));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlanDetail>> createPlanDetail({required String planId, required Map<String, dynamic> data}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.createPlanDetail(planId: planId, data: data));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlanDetail>> updatePlanDetail({required String detailId, required Map<String, dynamic> data}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.updatePlanDetail(detailId: detailId, data: data));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<VehiclePlanDetail>> updatePlanDetailStatus({required String detailId, required String estado, String? motivo}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.updatePlanDetailStatus(detailId: detailId, estado: estado, motivo: motivo));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

