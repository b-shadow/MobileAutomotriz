import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/domain/repositories/spare_parts_repository.dart';

class AsignarProveedorEta {
  final SparePartsRepository repository;
  AsignarProveedorEta(this.repository);

  Future<Result<SparePartRequestEntity>> call({
    required String solicitudId,
    required String proveedorId,
    String? eta,
    String? observaciones,
  }) =>
      repository.asignarProveedorEta(
        solicitudId: solicitudId,
        proveedorId: proveedorId,
        eta: eta,
        observaciones: observaciones,
      );
}
