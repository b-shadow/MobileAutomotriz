import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const AppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Appointment>>> getAppointments() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getAppointments();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Appointment>> getAppointmentDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.getAppointmentDetail(id));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Appointment>> createAppointment(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      return Success(await remoteDataSource.createAppointment(data));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Appointment>> cancelAppointment({
    required String id,
    required String motivo,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.cancelAppointment(id: id, motivo: motivo);
      final updated = await remoteDataSource.getAppointmentDetail(id);
      return Success(updated);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Appointment>> rescheduleAppointment({
    required String id,
    required DateTime fechaHoraInicio,
    required DateTime fechaHoraFin,
    required String motivoReprogramacion,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = <String, dynamic>{
        'fecha_hora_inicio_programada': fechaHoraInicio.toUtc().toIso8601String(),
        'fecha_hora_fin_programada': fechaHoraFin.toUtc().toIso8601String(),
        'motivo_reprogramacion': motivoReprogramacion,
      };
      final result = await remoteDataSource.rescheduleAppointment(id: id, data: data);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Appointment>> markNoShow({
    required String id,
    String? observacion,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      // El endpoint devuelve { mensaje, estado, no_show_marcado_at }
      // Hacemos GET al detalle para retornar la entidad completa actualizada.
      await remoteDataSource.markNoShow(id: id, observacion: observacion);
      final updated = await remoteDataSource.getAppointmentDetail(id);
      return Success(updated);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
