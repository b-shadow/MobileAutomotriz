import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/domain/repositories/spare_parts_repository.dart';

class GetSolicitudes
    implements UseCase<List<SparePartRequestEntity>, NoParams> {
  final SparePartsRepository repository;
  GetSolicitudes(this.repository);

  @override
  Future<Result<List<SparePartRequestEntity>>> call(NoParams params) =>
      repository.getSolicitudes();
}
