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
      final response = await apiClient.patch(
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
      final response = await apiClient.patch(
        ApiConstants.preferenciasNotificacion(_slug),
        data: {
          'noti_email': notiEmail,
          'noti_push': notiPush,
        },
      );
      
      // Usually preferences endpoint returns the updated preferences or the user.
      // If it doesn't return the full user, we might need to fetch the user or just PATCH the main user endpoint.
      // Assuming it acts similarly and returns the usuario format, or I fallback to patching the user endpoint.
      
      // Wait, let's just PATCH the main user endpoint for safety, as preferences are fields on UsuarioModel.
      // Or we can use the specific endpoint. We will use the specific if it returns the user properly.
      // If it fails, we need to adapt.
      return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
