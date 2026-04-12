import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';

class AuditSummaryModel extends AuditSummary {
  const AuditSummaryModel({
    required super.totalEventos,
    required super.eventosHoy,
    required super.eventosSemana,
    required super.usuariosActivos,
    required super.accionesFrecuentes,
  });

  factory AuditSummaryModel.fromJson(Map<String, dynamic> json) {
    List<String> toStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((item) => item.toString()).toList();
      }
      return const [];
    }

    final total = json['total_eventos'] ?? json['total'] ?? 0;
    final hoy = json['eventos_hoy'] ?? json['hoy'] ?? 0;
    final semana = json['eventos_ultima_semana'] ?? json['ultima_semana'] ?? 0;
    final usuarios = json['usuarios_con_cambios'] ?? json['usuarios_activos'] ?? 0;

    return AuditSummaryModel(
      totalEventos: total is int ? total : int.tryParse('$total') ?? 0,
      eventosHoy: hoy is int ? hoy : int.tryParse('$hoy') ?? 0,
      eventosSemana: semana is int ? semana : int.tryParse('$semana') ?? 0,
      usuariosActivos: usuarios is int ? usuarios : int.tryParse('$usuarios') ?? 0,
      accionesFrecuentes: toStringList(
        json['acciones_frecuentes'] ?? json['top_acciones'],
      ),
    );
  }
}

