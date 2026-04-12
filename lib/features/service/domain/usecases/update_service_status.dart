import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/repositories/service_repository.dart';

class UpdateServiceStatus
    implements UseCase<ServiceItem, UpdateServiceStatusParams> {
  final ServiceRepository repository;

  const UpdateServiceStatus(this.repository);

  @override
  Future<Result<ServiceItem>> call(UpdateServiceStatusParams params) async {
    return repository.updateServiceStatus(
      id: params.id,
      activo: params.activo,
      motivo: params.motivo,
    );
  }
}

class UpdateServiceStatusParams extends Equatable {
  final String id;
  final bool activo;
  final String? motivo;

  const UpdateServiceStatusParams({
    required this.id,
    required this.activo,
    this.motivo,
  });

  @override
  List<Object?> get props => [id, activo, motivo];
}

