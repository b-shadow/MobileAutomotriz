import 'package:equatable/equatable.dart';

class AuditSummary extends Equatable {
  final int totalEventos;
  final int eventosHoy;
  final int eventosSemana;
  final int usuariosActivos;
  final List<String> accionesFrecuentes;

  const AuditSummary({
    required this.totalEventos,
    required this.eventosHoy,
    required this.eventosSemana,
    required this.usuariosActivos,
    required this.accionesFrecuentes,
  });

  @override
  List<Object?> get props => [
        totalEventos,
        eventosHoy,
        eventosSemana,
        usuariosActivos,
        accionesFrecuentes,
      ];
}

