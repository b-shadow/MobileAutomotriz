import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';

class WorkspaceScheduleModel extends WorkspaceSchedule {
  const WorkspaceScheduleModel({
    required super.id,
    required super.diaSemana,
    required super.horaInicio,
    required super.horaFin,
    required super.activo,
  });

  factory WorkspaceScheduleModel.fromJson(Map<String, dynamic> json) {
    final diaRaw = json['dia_semana'];
    return WorkspaceScheduleModel(
      id: (json['id'] ?? '').toString(),
      diaSemana: diaRaw is int ? diaRaw : int.tryParse('$diaRaw') ?? 0,
      horaInicio: (json['hora_inicio'] ?? '').toString(),
      horaFin: (json['hora_fin'] ?? '').toString(),
      activo: json['activo'] as bool? ?? true,
    );
  }
}

