import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';

abstract class WorkspaceRepository {
  Future<Result<List<WorkspaceSpace>>> getSpaces();
  Future<Result<WorkspaceSpace>> createSpace(Map<String, dynamic> data);
  Future<Result<WorkspaceSpace>> updateSpaceActive({
    required String spaceId,
    required bool activo,
    String? motivo,
  });

  Future<Result<List<WorkspaceSchedule>>> getSpaceSchedules(String spaceId);
  Future<Result<WorkspaceSchedule>> createSpaceSchedule({
    required String spaceId,
    required Map<String, dynamic> data,
  });
  Future<Result<WorkspaceSchedule>> updateSpaceSchedule({
    required String spaceId,
    required String scheduleId,
    required Map<String, dynamic> data,
  });
}

