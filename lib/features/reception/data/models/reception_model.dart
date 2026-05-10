import 'package:mobile1_app/features/reception/domain/entities/reception.dart';

class ReceptionModel extends Reception {
  const ReceptionModel({
    required super.id,
    required super.citaId,
    required super.vehiculoPlaca,
    required super.vehiculoMarca,
    required super.vehiculoModelo,
    super.vehiculoAnio,
    super.clienteNombre,
    super.clienteEmail,
    super.clienteTelefono,
    required super.fechaRecepcion,
    required super.kilometrajeIngreso,
    required super.nivelCombustible,
    super.condicionGeneral,
    super.observaciones,
    super.asesorNombre,
    super.fechaRecogida,
  });

  factory ReceptionModel.fromJson(Map<String, dynamic> json) {
    // El backend puede retornar el serializer lista (compact) o detalle (completo)
    final citaId = (json['cita_id'] ?? json['cita'] ?? '').toString();
    final placa = (json['vehiculo_placa'] ?? '').toString();
    final marcaModelo = (json['vehiculo_marca_modelo'] ?? '').toString();
    final parts = marcaModelo.split(' ');
    final marca = parts.isNotEmpty ? parts.first : '';
    final modelo = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return ReceptionModel(
      id: (json['id'] ?? '').toString(),
      citaId: citaId,
      vehiculoPlaca: placa,
      vehiculoMarca: json['vehiculo_marca']?.toString() ?? marca,
      vehiculoModelo: json['vehiculo_modelo']?.toString() ?? modelo,
      vehiculoAnio: json['vehiculo_ano']?.toString(),
      clienteNombre: json['cliente_nombre']?.toString(),
      clienteEmail: json['cliente_email']?.toString(),
      clienteTelefono: json['cliente_telefono']?.toString(),
      fechaRecepcion: json['fecha_recepcion'] != null
          ? DateTime.parse(json['fecha_recepcion'].toString())
          : DateTime.now(),
      kilometrajeIngreso:
          int.tryParse(json['kilometraje_ingreso']?.toString() ?? '0') ?? 0,
      nivelCombustible:
          (json['nivel_combustible'] ?? '1/2').toString(),
      condicionGeneral: json['condicion_general']?.toString(),
      observaciones: json['observaciones']?.toString(),
      asesorNombre: json['asesor_nombre']?.toString(),
      fechaRecogida: json['fecha_recogida'] != null
          ? DateTime.parse(json['fecha_recogida'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cita_id': citaId,
        'vehiculo_placa': vehiculoPlaca,
        'kilometraje_ingreso': kilometrajeIngreso,
        'nivel_combustible': nivelCombustible,
        if (observaciones != null) 'observaciones': observaciones,
      };
}
