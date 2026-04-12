import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class UpdateSpaceSchedule
    implements UseCase<WorkspaceSchedule, UpdateSpaceScheduleParams> {
  final WorkspaceRepository repository;

  const UpdateSpaceSchedule(this.repository);

  @override
  Future<Result<WorkspaceSchedule>> call(
    UpdateSpaceScheduleParams params,
  ) async {
    return repository.updateSpaceSchedule(
      spaceId: params.spaceId,
      scheduleId: params.scheduleId,
      data: params.data,
    );
  }
}

class UpdateSpaceScheduleParams extends Equatable {
  final String spaceId;
  final String scheduleId;
  final Map<String, dynamic> data;

  const UpdateSpaceScheduleParams({
    required this.spaceId,
    required this.scheduleId,
    required this.data,
  });

  @override
  List<Object?> get props => [spaceId, scheduleId, data];
}

