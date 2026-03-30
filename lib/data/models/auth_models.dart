/// Modelos de autenticación
class Usuario {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String empresa;

  Usuario({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.empresa,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      empresa: json['empresa'] ?? '',
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final Usuario usuario;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
      usuario: Usuario.fromJson(json['user'] ?? {}),
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final String empresaNombre;
  final String empresaSlug;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.empresaNombre,
    required this.empresaSlug,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombres': nombres,
    'apellidos': apellidos,
    'empresa_nombre': empresaNombre,
    'empresa_slug': empresaSlug,
  };
}

