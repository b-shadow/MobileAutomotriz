import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class UpdateSpaceActive
    implements UseCase<WorkspaceSpace, UpdateSpaceActiveParams> {
  final WorkspaceRepository repository;

  const UpdateSpaceActive(this.repository);

  @override
  Future<Result<WorkspaceSpace>> call(UpdateSpaceActiveParams params) async {
    return repository.updateSpaceActive(
      spaceId: params.spaceId,
      activo: params.activo,
      motivo: params.motivo,
    );
  }
}

class UpdateSpaceActiveParams extends Equatable {
  final String spaceId;
  final bool activo;
  final String? motivo;

  const UpdateSpaceActiveParams({
    required this.spaceId,
    required this.activo,
    this.motivo,
  });

  @override
  List<Object?> get props => [spaceId, activo, motivo];
}

