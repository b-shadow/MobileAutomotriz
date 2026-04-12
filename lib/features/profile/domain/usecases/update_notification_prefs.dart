import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import '../repositories/profile_repository.dart';

class UpdateNotificationPrefsParams {
  final String id;
  final bool notiEmail;
  final bool notiPush;

  const UpdateNotificationPrefsParams({
    required this.id,
    required this.notiEmail,
    required this.notiPush,
  });
}

class UpdateNotificationPrefs implements UseCase<UsuarioModel, UpdateNotificationPrefsParams> {
  final ProfileRepository repository;

  UpdateNotificationPrefs(this.repository);

  @override
  Future<Result<UsuarioModel>> call(UpdateNotificationPrefsParams params) {
    return repository.updateNotificationPrefs(
      id: params.id,
      notiEmail: params.notiEmail,
      notiPush: params.notiPush,
    );
  }
}
