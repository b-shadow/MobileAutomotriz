import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/domain/repositories/spare_parts_repository.dart';

class AprobarSolicitud {
  final SparePartsRepository repository;
  AprobarSolicitud(this.repository);

  Future<Result<SparePartRequestEntity>> call({
    required String solicitudId,
    String? observacionesAsesor,
  }) =>
      repository.aprobarSolicitud(
        solicitudId: solicitudId,
        observacionesAsesor: observacionesAsesor,
      );
}
