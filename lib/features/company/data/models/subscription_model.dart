import 'package:mobile1_app/features/company/domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.empresaId,
    required super.planId,
    required super.planNombre,
    required super.planPrecioCentavos,
    super.inicio,
    super.fin,
    required super.estado,
    required super.diasRestantes,
    super.referenciaPago,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (_) {
        return null;
      }
    }

    final plan = json['plan'] is Map<String, dynamic>
        ? json['plan'] as Map<String, dynamic>
        : null;

    final empresaValue = json['empresa'];
    final empresa = empresaValue is Map<String, dynamic>
        ? empresaValue
        : null;

    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      empresaId: (json['empresa_id'] as String?) ??
          (json['empresa'] as String?) ??
          (empresa?['id'] as String?) ??
          '',
      planId: (json['plan_id'] as String?) ??
          (plan?['id'] as String?) ??
          '',
      planNombre: (json['plan_nombre'] as String?) ??
          (plan?['nombre'] as String?) ??
          'Desconocido',
      planPrecioCentavos: (json['plan_precio_centavos'] as int?) ??
          (plan?['precio_centavos'] as int?) ??
          0,
      inicio: parseDate(json['inicio']),
      fin: parseDate(json['fin']),
      estado: json['estado'] as String? ?? 'INACTIVA',
      diasRestantes: json['dias_restantes'] as int? ?? 0,
      referenciaPago: json['referencia_pago'] as String?,
    );
  }
}
