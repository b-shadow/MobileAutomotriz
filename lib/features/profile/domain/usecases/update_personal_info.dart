import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import '../repositories/profile_repository.dart';

class UpdatePersonalInfoParams {
  final String id;
  final String nombres;
  final String apellidos;
  final String? telefono;

  const UpdatePersonalInfoParams({
    required this.id,
    required this.nombres,
    required this.apellidos,
    this.telefono,
  });
}

class UpdatePersonalInfo implements UseCase<UsuarioModel, UpdatePersonalInfoParams> {
  final ProfileRepository repository;

  UpdatePersonalInfo(this.repository);

  @override
  Future<Result<UsuarioModel>> call(UpdatePersonalInfoParams params) {
    return repository.updatePersonalInfo(
      id: params.id,
      nombres: params.nombres,
      apellidos: params.apellidos,
      telefono: params.telefono,
    );
  }
}
