import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';

class ProgressLogModel extends ProgressLog {
  const ProgressLogModel({
    required super.id,
    required super.citaId,
    super.ordenDetalleId,
    required super.tipo,
    required super.estadoNuevo,
    required super.mensaje,
    required super.porcentajeAvance,
    required super.visibleCliente,
    super.registradoPor,
    required super.createdAt,
  });

  factory ProgressLogModel.fromJson(Map<String, dynamic> json) {
    return ProgressLogModel(
      id: (json['id'] ?? '').toString(),
      citaId: (json['cita'] ?? '').toString(),
      ordenDetalleId: json['orden_detalle']?.toString(),
      tipo: (json['tipo'] ?? 'GENERAL').toString(),
      estadoNuevo: (json['estado_nuevo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      porcentajeAvance: int.tryParse(json['porcentaje_avance']?.toString() ?? '0') ?? 0,
      visibleCliente: json['visible_cliente'] == true,
      registradoPor: json['registrado_por']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}
