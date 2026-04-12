import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';

abstract class ProfileRepository {
  /// Update personal info (Nombres, Apellidos, Teléfono).
  Future<Result<UsuarioModel>> updatePersonalInfo({
    required String id,
    required String nombres,
    required String apellidos,
    required String? telefono,
  });

  /// Change user password.
  Future<Result<void>> changePassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  });

  /// Update notification preferences.
  Future<Result<UsuarioModel>> updateNotificationPrefs({
    required String id,
    required bool notiEmail,
    required bool notiPush,
  });
}
