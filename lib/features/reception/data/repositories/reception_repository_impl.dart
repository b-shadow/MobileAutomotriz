import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/reception/data/datasources/reception_remote_data_source.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';
import 'package:mobile1_app/features/reception/domain/repositories/reception_repository.dart';

class ReceptionRepositoryImpl implements ReceptionRepository {
  final ReceptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ReceptionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Reception>> createReception({
    required String citaId,
    required int kilometrajeIngreso,
    required String nivelCombustible,
    String? observaciones,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = <String, dynamic>{
        'cita_id': citaId,
        'kilometraje_ingreso': kilometrajeIngreso,
        'nivel_combustible': nivelCombustible,
        if (observaciones != null && observaciones.isNotEmpty)
          'observaciones': observaciones,
      };
      final result = await remoteDataSource.createReception(data);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<Reception>>> getReceptions() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getReceptions();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Reception>> getReceptionDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.getReceptionDetail(id));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<Appointment>>> getCitasPendientes() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getCitasPendientes();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
