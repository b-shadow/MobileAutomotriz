import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';
import 'package:mobile1_app/features/reception/domain/repositories/reception_repository.dart';

class CreateReceptionParams extends Equatable {
  final String citaId;
  final int kilometrajeIngreso;
  final String nivelCombustible;
  final String? observaciones;

  const CreateReceptionParams({
    required this.citaId,
    required this.kilometrajeIngreso,
    required this.nivelCombustible,
    this.observaciones,
  });

  @override
  List<Object?> get props =>
      [citaId, kilometrajeIngreso, nivelCombustible, observaciones];
}

class CreateReception implements UseCase<Reception, CreateReceptionParams> {
  final ReceptionRepository repository;
  CreateReception(this.repository);

  @override
  Future<Result<Reception>> call(CreateReceptionParams params) {
    return repository.createReception(
      citaId: params.citaId,
      kilometrajeIngreso: params.kilometrajeIngreso,
      nivelCombustible: params.nivelCombustible,
      observaciones: params.observaciones,
    );
  }
}
