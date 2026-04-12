import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class CreateSpaceSchedule
    implements UseCase<WorkspaceSchedule, CreateSpaceScheduleParams> {
  final WorkspaceRepository repository;

  const CreateSpaceSchedule(this.repository);

  @override
  Future<Result<WorkspaceSchedule>> call(
    CreateSpaceScheduleParams params,
  ) async {
    return repository.createSpaceSchedule(
      spaceId: params.spaceId,
      data: params.data,
    );
  }
}

class CreateSpaceScheduleParams extends Equatable {
  final String spaceId;
  final Map<String, dynamic> data;

  const CreateSpaceScheduleParams({
    required this.spaceId,
    required this.data,
  });

  @override
  List<Object?> get props => [spaceId, data];
}

