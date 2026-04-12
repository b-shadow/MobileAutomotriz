import '../../domain/entities/user.dart';

/// DTO for User — handles JSON serialization from Django backend.
///
/// Backend format (from login):
/// ```json
/// {
///   "id": "uuid",
///   "email": "user@example.com",
///   "nombres": "Juan",
///   "apellidos": "Pérez",
///   "empresa_id": "uuid",
///   "rol": "USUARIO",
///   "rol_id": "uuid"
/// }
/// ```
///
/// Note: `tenant` info (empresa nombre, slug) comes as a separate
/// object in the API response and is passed via the [tenant] parameter.
class UsuarioModel extends User {
  const UsuarioModel({
    required super.id,
    required super.email,
    required super.nombres,
    required super.apellidos,
    super.telefono,
    required super.rolId,
    required super.rolNombre,
    required super.empresaId,
    required super.empresaNombre,
    required super.empresaSlug,
    super.isActive,
    super.notiEmail,
    super.notiPush,
  });

  /// Parse from backend JSON response.
  ///
  /// [tenant] is the tenant object from the login/register response root,
  /// containing empresa id, nombre, and slug. When restoring from storage,
  /// tenant data is embedded in the JSON itself.
  factory UsuarioModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? tenant,
  }) {
    // Support both:
    // - API response: tenant passed as separate parameter
    // - Storage restore: tenant embedded in JSON under 'tenant' key
    final tenantData = tenant ?? json['tenant'] as Map<String, dynamic>?;

    // rol can be a String ("USUARIO") or an object { id, nombre }
    final rolRaw = json['rol'];
    String rolNombre;
    String rolId;

    if (rolRaw is Map<String, dynamic>) {
      rolNombre = rolRaw['nombre'] as String? ?? 'USUARIO';
      rolId = (rolRaw['id'] ?? '').toString();
    } else {
      rolNombre = (rolRaw ?? 'USUARIO').toString();
      rolId = (json['rol_id'] ?? '').toString();
    }

    return UsuarioModel(
      id: (json['id'] ?? '').toString(),
      email: json['email'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      telefono: json['telefono'] as String?,
      rolId: rolId,
      rolNombre: rolNombre,
      empresaId: (json['empresa_id'] ?? tenantData?['id'] ?? '').toString(),
      empresaNombre: tenantData?['nombre'] as String? ?? '',
      empresaSlug: tenantData?['slug'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      notiEmail: json['noti_email'] as bool? ?? true,
      notiPush: json['noti_push'] as bool? ?? true,
    );
  }

  // ... existing fields and methods ...

  /// Returns a new UsuarioModel by copying current properties and replacing provided ones.
  UsuarioModel copyWith({
    String? id,
    String? email,
    String? nombres,
    String? apellidos,
    String? telefono,
    String? rolId,
    String? rolNombre,
    String? empresaId,
    String? empresaNombre,
    String? empresaSlug,
    bool? isActive,
    bool? notiEmail,
    bool? notiPush,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      rolId: rolId ?? this.rolId,
      rolNombre: rolNombre ?? this.rolNombre,
      empresaId: empresaId ?? this.empresaId,
      empresaNombre: empresaNombre ?? this.empresaNombre,
      empresaSlug: empresaSlug ?? this.empresaSlug,
      isActive: isActive ?? this.isActive,
      notiEmail: notiEmail ?? this.notiEmail,
      notiPush: notiPush ?? this.notiPush,
    );
  }

  /// Convert to JSON for local storage.
  ///
  /// Embeds tenant data so it can be restored without needing
  /// a separate tenant object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'rol': rolNombre,
      'rol_id': rolId,
      'empresa_id': empresaId,
      'tenant': {
        'id': empresaId,
        'nombre': empresaNombre,
        'slug': empresaSlug,
      },
      'is_active': isActive,
      'noti_email': notiEmail,
      'noti_push': notiPush,
    };
  }
}
