import 'package:mobile1_app/features/company/domain/entities/plan.dart';

class PlanModel extends Plan {
  const PlanModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    super.descripcion,
    required super.precioCentavos,
    required super.duracionDias,
    required super.moneda,
    required super.activo,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      precioCentavos: json['precio_centavos'] as int? ?? 0,
      duracionDias: json['duracion_dias'] as int? ?? 0,
      moneda: json['moneda'] as String? ?? 'USD',
      activo: json['activo'] as bool? ?? true,
    );
  }
}
