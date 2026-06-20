import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UsuarioModel> updatePersonalInfo({
    required String id,
    required String nombres,
    required String apellidos,
    required String? telefono,
  });

  Future<void> changePassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  });

  Future<UsuarioModel> updateNotificationPrefs({
    required String id,
    required bool notiEmail,
    required bool notiPush,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  const ProfileRemoteDataSourceImpl({required this.apiClient});

  String get _slug => EnvConfig.tenantSlug;

  @override
  Future<UsuarioModel> updatePersonalInfo({
    required String id,
    required String nombres,
    required String apellidos,
    required String? telefono,
  }) async {
    try {
      await apiClient.patch(
        ApiConstants.usuario(_slug, id),
        data: {
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
        },
      );
      // Ignoramos la forma en que el backend responde (ya que puede traer JSONs anidados 
      // incompletos o vacíos) y mejor devolvemos exactamente lo que empujamos (que ya fue aprobado 200 OK)
      return UsuarioModel(
        id: id,
        email: '',
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        rolId: '',
        rolNombre: '',
        empresaId: '',
        empresaNombre: '',
        empresaSlug: '',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.post(
        ApiConstants.cambiarContrasena(_slug, id),
        data: {
          'old_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UsuarioModel> updateNotificationPrefs({
    required String id,
    required bool notiEmail,
    required bool notiPush,
  }) async {
    try {
      // Assuming preferences updates use the specific endpoint if provided,
      // but the API constants has `preferenciasNotificacion(String slug)` without ID.
      // E.g. /api/{slug}/usuarios/preferencias-notificacion/
      // Backend likely infers user from JWT.
      await apiClient.patch(
        ApiConstants.preferenciasNotificacion(_slug),
        data: {
          'noti_email': notiEmail,
          'noti_push': notiPush,
        },
      );

      return UsuarioModel(
        id: id,
        email: '',
        nombres: '',
        apellidos: '',
        telefono: null,
        rolId: '',
        rolNombre: '',
        empresaId: '',
        empresaNombre: '',
        empresaSlug: '',
        notiEmail: notiEmail,
        notiPush: notiPush,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
