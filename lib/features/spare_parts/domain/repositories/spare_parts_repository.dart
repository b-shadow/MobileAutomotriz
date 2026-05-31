import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';

abstract class SparePartsRepository {
  Future<Result<List<SparePartRequestEntity>>> getSolicitudes();

  Future<Result<SparePartRequestEntity>> aprobarSolicitud({
    required String solicitudId,
    String? observacionesAsesor,
  });

  Future<Result<SparePartRequestEntity>> enProcesoAlmacen({
    required String solicitudId,
    String? observacionesAlmacen,
  });

  Future<Result<SparePartRequestEntity>> marcarEntregada({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles,
  });

  Future<Result<SparePartRequestEntity>> asignarProveedorEta({
    required String solicitudId,
    required String proveedorId,
    String? eta,
    String? observaciones,
  });
}
