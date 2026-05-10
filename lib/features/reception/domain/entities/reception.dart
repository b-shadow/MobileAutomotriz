import 'package:equatable/equatable.dart';

/// Representa una recepción de vehículo registrada.
class Reception extends Equatable {
  final String id;
  final String citaId;
  final String vehiculoPlaca;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final String? vehiculoAnio;
  final String? clienteNombre;
  final String? clienteEmail;
  final String? clienteTelefono;
  final DateTime fechaRecepcion;
  final int kilometrajeIngreso;
  final String nivelCombustible;
  final String? condicionGeneral;
  final String? observaciones;
  final String? asesorNombre;
  final DateTime? fechaRecogida;

  const Reception({
    required this.id,
    required this.citaId,
    required this.vehiculoPlaca,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    this.vehiculoAnio,
    this.clienteNombre,
    this.clienteEmail,
    this.clienteTelefono,
    required this.fechaRecepcion,
    required this.kilometrajeIngreso,
    required this.nivelCombustible,
    this.condicionGeneral,
    this.observaciones,
    this.asesorNombre,
    this.fechaRecogida,
  });

  bool get yaRecogido => fechaRecogida != null;

  @override
  List<Object?> get props => [id, citaId, vehiculoPlaca, fechaRecepcion];
}
