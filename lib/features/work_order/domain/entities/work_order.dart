import 'package:equatable/equatable.dart';

class Mechanic extends Equatable {
  final String id;
  final String nombre;
  final String email;

  const Mechanic({
    required this.id,
    required this.nombre,
    required this.email,
  });

  @override
  List<Object?> get props => [id, nombre, email];
}

class WorkOrderMechanic extends Equatable {
  final String id;
  final String mecanico; // ID del mecánico
  final String mecanicoNombres;
  final bool esPrincipal;

  const WorkOrderMechanic({
    required this.id,
    required this.mecanico,
    required this.mecanicoNombres,
    required this.esPrincipal,
  });

  @override
  List<Object?> get props => [id, mecanico, mecanicoNombres, esPrincipal];
}

class WorkOrderDetail extends Equatable {
  final String id;
  final String? servicioCatalogo;
  final String servicioNombre;
  final String estado;
  final int tiempoEstandarMin;
  final int tiempoRealMin;
  final String? mecanicoAsignado; // ID del mecánico
  final String? mecanicoNombres;

  const WorkOrderDetail({
    required this.id,
    this.servicioCatalogo,
    required this.servicioNombre,
    required this.estado,
    required this.tiempoEstandarMin,
    required this.tiempoRealMin,
    this.mecanicoAsignado,
    this.mecanicoNombres,
  });

  @override
  List<Object?> get props => [
        id,
        servicioCatalogo,
        servicioNombre,
        estado,
        tiempoEstandarMin,
        tiempoRealMin,
        mecanicoAsignado,
        mecanicoNombres,
      ];
}

class WorkOrder extends Equatable {
  final String id;
  final String citaId;
  final String numero;
  final String estado;
  final String? observaciones;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final List<WorkOrderDetail> detalles;
  final List<WorkOrderMechanic> mecanicosAsignados;
  
  // Datos extra para UI
  final String? vehiculoPlaca;
  final String? clienteNombre;

  const WorkOrder({
    required this.id,
    required this.citaId,
    required this.numero,
    required this.estado,
    this.observaciones,
    required this.fechaApertura,
    this.fechaCierre,
    this.detalles = const [],
    this.mecanicosAsignados = const [],
    this.vehiculoPlaca,
    this.clienteNombre,
  });

  @override
  List<Object?> get props => [
        id,
        citaId,
        numero,
        estado,
        observaciones,
        fechaApertura,
        fechaCierre,
        detalles,
        mecanicosAsignados,
      ];
}
