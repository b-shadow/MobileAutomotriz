import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.estado,
    required super.canalOrigen,
    required super.fechaHoraInicio,
    required super.fechaHoraFin,
    required super.duracionEstimadaMin,
    required super.vehiculoId,
    required super.vehiculoPlaca,
    required super.vehiculoMarca,
    required super.vehiculoModelo,
    super.motivoVisita,
    super.observacionesCliente,
    super.motivoCancelacion,
    super.clienteId,
    super.clienteNombre,
    super.clienteEmail,
    super.asesorNombre,
    super.planServicioId,
    super.detalles,
    super.espaciosSegmentos,
    super.createdAt,
    super.reprogramacionesCount,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    DateTime? parseDateOpt(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    // Vehículo — puede venir como objeto anidado o campos planos
    final vehiculoRaw = json['vehiculo'];
    final Map<String, dynamic>? vehiculoMap =
        vehiculoRaw is Map<String, dynamic> ? vehiculoRaw : null;

    final vehiculoId = (vehiculoMap?['id'] ?? json['vehiculo_id'] ?? '').toString();
    final vehiculoPlaca = (vehiculoMap?['placa'] ?? json['vehiculo_placa'] ?? '').toString();
    final vehiculoMarca = (vehiculoMap?['marca'] ?? json['vehiculo_marca'] ?? '').toString();
    final vehiculoModelo = (vehiculoMap?['modelo'] ?? json['vehiculo_modelo'] ?? '').toString();

    // Cliente
    final clienteRaw = json['cliente'];
    final Map<String, dynamic>? clienteMap =
        clienteRaw is Map<String, dynamic> ? clienteRaw : null;
    final clienteId = clienteMap?['id']?.toString();
    final clienteNombre = clienteMap != null
        ? '${clienteMap['nombres'] ?? ''} ${clienteMap['apellidos'] ?? ''}'.trim()
        : null;
    final clienteEmail = clienteMap?['email']?.toString();

    // Asesor
    final asesorRaw = json['asesor_responsable'];
    final Map<String, dynamic>? asesorMap =
        asesorRaw is Map<String, dynamic> ? asesorRaw : null;
    final asesorNombre = asesorMap != null
        ? '${asesorMap['nombres'] ?? ''} ${asesorMap['apellidos'] ?? ''}'.trim()
        : null;

    // Plan de servicio
    final planRaw = json['plan_servicio'];
    final planServicioId = planRaw is Map<String, dynamic>
        ? planRaw['id']?.toString()
        : planRaw?.toString();

    // Detalles
    final detallesRaw = json['detalles'];
    final List<AppointmentDetailItem> detalles = [];
    if (detallesRaw is List) {
      for (final d in detallesRaw) {
        if (d is Map<String, dynamic>) {
          detalles.add(_parseDetail(d));
        }
      }
    }

    // Espacios / Segmentos
    final espaciosRaw = json['espacios_segmentos'];
    final List<AppointmentSegment> espacios = [];
    if (espaciosRaw is List) {
      for (final e in espaciosRaw) {
        if (e is Map<String, dynamic>) {
          espacios.add(_parseSegment(e));
        }
      }
    }

    return AppointmentModel(
      id: (json['id'] ?? '').toString(),
      estado: (json['estado'] ?? 'PROGRAMADA').toString(),
      canalOrigen: (json['canal_origen'] ?? 'CLIENTE').toString(),
      fechaHoraInicio: parseDate(json['fecha_hora_inicio_programada']),
      fechaHoraFin: parseDate(json['fecha_hora_fin_programada']),
      duracionEstimadaMin: (json['duracion_estimada_min'] as num?)?.toInt() ?? 0,
      vehiculoId: vehiculoId,
      vehiculoPlaca: vehiculoPlaca,
      vehiculoMarca: vehiculoMarca,
      vehiculoModelo: vehiculoModelo,
      motivoVisita: json['motivo_visita']?.toString(),
      observacionesCliente: json['observaciones_cliente']?.toString(),
      motivoCancelacion: json['motivo_cancelacion']?.toString(),
      clienteId: clienteId,
      clienteNombre: clienteNombre,
      clienteEmail: clienteEmail,
      asesorNombre: asesorNombre,
      planServicioId: planServicioId,
      detalles: detalles,
      espaciosSegmentos: espacios,
      createdAt: parseDateOpt(json['created_at']),
      reprogramacionesCount: (json['reprogramaciones_count'] as num?)?.toInt() ?? 0,
    );
  }

  static AppointmentDetailItem _parseDetail(Map<String, dynamic> d) {
    final servicioRaw = d['servicio_catalogo'];
    final Map<String, dynamic>? servicioMap =
        servicioRaw is Map<String, dynamic> ? servicioRaw : null;

    return AppointmentDetailItem(
      id: (d['id'] ?? '').toString(),
      servicioNombre: servicioMap?['nombre']?.toString() ?? d['servicio_nombre']?.toString(),
      servicioCodigo: servicioMap?['codigo']?.toString(),
      estado: (d['estado'] ?? 'PROGRAMADO').toString(),
      tiempoEstandarMin: (d['tiempo_estandar_min'] as num?)?.toInt() ?? 0,
      precioReferencial: (d['precio_referencial'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static AppointmentSegment _parseSegment(Map<String, dynamic> e) {
    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final espacioRaw = e['espacio_trabajo'];
    final Map<String, dynamic>? espacioMap =
        espacioRaw is Map<String, dynamic> ? espacioRaw : null;

    return AppointmentSegment(
      id: (e['id'] ?? '').toString(),
      espacioNombre: espacioMap?['nombre']?.toString(),
      tipoSegmento: (e['tipo_segmento'] ?? 'TALLER').toString(),
      estadoSegmento: (e['estado_segmento'] ?? 'RESERVADO').toString(),
      inicioProgramado: parseDate(e['inicio_programado']),
      finProgramado: parseDate(e['fin_programado']),
    );
  }
}
