import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String id;
  final String empresaId;
  final String planId;
  final String planNombre;
  final int planPrecioCentavos; // In cents to avoid float precision issues natively
  final DateTime? inicio;
  final DateTime? fin;
  final String estado;
  final int diasRestantes;
  final String? referenciaPago;

  const Subscription({
    required this.id,
    required this.empresaId,
    required this.planId,
    required this.planNombre,
    required this.planPrecioCentavos,
    this.inicio,
    this.fin,
    required this.estado,
    required this.diasRestantes,
    this.referenciaPago,
  });

  bool get isActive => estado == 'ACTIVA';

  @override
  List<Object?> get props => [
        id,
        empresaId,
        planId,
        planNombre,
        planPrecioCentavos,
        inicio,
        fin,
        estado,
        diasRestantes,
        referenciaPago,
      ];
}
