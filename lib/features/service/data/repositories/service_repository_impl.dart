import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/service/data/datasources/service_remote_data_source.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<ServiceItem>>> getServices() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final items = await remoteDataSource.getServices();
      return Success(items);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<ServiceItem>> createService(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final item = await remoteDataSource.createService(data);
      return Success(item);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<ServiceItem>> updateService({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final item = await remoteDataSource.updateService(id: id, data: data);
      return Success(item);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<ServiceItem>> updateServiceStatus({
    required String id,
    required bool activo,
    String? motivo,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final item = await remoteDataSource.updateServiceStatus(
        id: id,
        activo: activo,
        motivo: motivo,
      );
      return Success(item);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

