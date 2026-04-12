import 'package:mobile1_app/features/company/domain/entities/empresa.dart';

class EmpresaModel extends Empresa {
  const EmpresaModel({
    required super.id,
    required super.nombre,
    required super.slug,
    required super.estado,
    super.estadoDisplay,
    super.suscripcionHasta,
    super.createdAt,
    super.updatedAt,
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      estado: json['estado'] as String,
      estadoDisplay: json['estado_display'] as String?,
      suscripcionHasta: json['suscripcion_hasta'] != null
          ? DateTime.tryParse(json['suscripcion_hasta'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'slug': slug,
      'estado': estado,
      'estado_display': estadoDisplay,
      'suscripcion_hasta': suscripcionHasta?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
