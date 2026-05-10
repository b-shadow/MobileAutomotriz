import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/reception/domain/repositories/reception_repository.dart';

class GetCitasPendientesRecepcion
    implements UseCase<List<Appointment>, NoParams> {
  final ReceptionRepository repository;
  GetCitasPendientesRecepcion(this.repository);

  @override
  Future<Result<List<Appointment>>> call(NoParams params) =>
      repository.getCitasPendientes();
}
