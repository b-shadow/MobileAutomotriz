import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class GetSpaceSchedules
    implements UseCase<List<WorkspaceSchedule>, GetSpaceSchedulesParams> {
  final WorkspaceRepository repository;

  const GetSpaceSchedules(this.repository);

  @override
  Future<Result<List<WorkspaceSchedule>>> call(
    GetSpaceSchedulesParams params,
  ) async {
    return repository.getSpaceSchedules(params.spaceId);
  }
}

class GetSpaceSchedulesParams extends Equatable {
  final String spaceId;

  const GetSpaceSchedulesParams({required this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}

