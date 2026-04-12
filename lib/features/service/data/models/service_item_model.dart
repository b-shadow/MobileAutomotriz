import 'package:mobile1_app/features/service/domain/entities/service_item.dart';

class ServiceItemModel extends ServiceItem {
  const ServiceItemModel({
    required super.id,
    required super.nombre,
    required super.codigo,
    required super.precio,
    required super.tiempo,
    super.descripcion,
    required super.activo,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    final precioRaw = json['precio_base'] ?? json['precio'];
    final tiempoRaw =
        json['tiempo_estandar_min'] ?? json['tiempo'] ?? json['duracion_minutos'];

    return ServiceItemModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      codigo: (json['codigo'] ?? json['código'] ?? '').toString(),
      precio: precioRaw is num
          ? precioRaw.toDouble()
          : double.tryParse('$precioRaw') ?? 0,
      tiempo: tiempoRaw is int ? tiempoRaw : int.tryParse('$tiempoRaw') ?? 0,
      descripcion: (json['descripcion'] ?? json['descripción']) as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}

