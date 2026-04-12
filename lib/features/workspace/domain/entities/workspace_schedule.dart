import 'package:equatable/equatable.dart';

class WorkspaceSchedule extends Equatable {
  final String id;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;

  const WorkspaceSchedule({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, diaSemana, horaInicio, horaFin, activo];
}

