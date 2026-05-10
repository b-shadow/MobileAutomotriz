import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';

abstract class ReceptionRepository {
  /// Registra una nueva recepción de vehículo.
  Future<Result<Reception>> createReception({
    required String citaId,
    required int kilometrajeIngreso,
    required String nivelCombustible,
    String? observaciones,
  });

  /// Lista recepciones registradas.
  Future<Result<List<Reception>>> getReceptions();

  /// Detalle de una recepción.
  Future<Result<Reception>> getReceptionDetail(String id);

  /// Citas en estado PROGRAMADA/EN_ESPERA_INGRESO sin recepción aún.
  Future<Result<List<Appointment>>> getCitasPendientes();
}
