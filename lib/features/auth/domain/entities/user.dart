import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String? telefono;
  final String rolId;
  final String rolNombre;
  final String empresaId;
  final String empresaNombre;
  final String empresaSlug;
  final bool isActive;
  final bool notiEmail;
  final bool notiPush;

  const User({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    this.telefono,
    required this.rolId,
    required this.rolNombre,
    required this.empresaId,
    required this.empresaNombre,
    required this.empresaSlug,
    this.isActive = true,
    this.notiEmail = true,
    this.notiPush = true,
  });

  /// Full name: "nombres apellidos"
  String get fullName => '$nombres $apellidos'.trim();

  /// Whether the user has the ADMIN role.
  bool get isAdmin => rolNombre.toUpperCase() == 'ADMIN';

  /// Whether the user has the USUARIO (client) role.
  bool get isUsuario => rolNombre.toUpperCase() == 'USUARIO';

  /// Whether the user has the ASESOR DE SERVICIO role.
  bool get isAsesor => rolNombre.toUpperCase() == 'ASESOR DE SERVICIO';

  /// Whether the user has the MECÁNICO role.
  bool get isMecanico => rolNombre.toUpperCase() == 'MECÁNICO';

  @override
  List<Object?> get props => [
        id,
        email,
        nombres,
        apellidos,
        telefono,
        rolId,
        rolNombre,
        empresaId,
        empresaNombre,
        empresaSlug,
        isActive,
        notiEmail,
        notiPush,
      ];
}
