import 'usuario_model.dart';

/// DTO for login/register API responses.
///
/// Actual backend format:
/// ```json
/// {
///   "usuario": { "id", "email", "nombres", "apellidos", "empresa_id", "rol", "rol_id" },
///   "tenant": { "id", "slug", "nombre" },
///   "tokens": { "access": "eyJ...", "refresh": "eyJ..." }
/// }
/// ```
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final UsuarioModel usuario;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.usuario,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>;
    final tenant = json['tenant'] as Map<String, dynamic>?;

    return LoginResponseModel(
      accessToken: tokens['access'] as String,
      refreshToken: tokens['refresh'] as String,
      usuario: UsuarioModel.fromJson(
        json['usuario'] as Map<String, dynamic>,
        tenant: tenant,
      ),
    );
  }
}
