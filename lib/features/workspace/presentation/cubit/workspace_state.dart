import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';

abstract class WorkspaceState {
  const WorkspaceState();
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceLoaded extends WorkspaceState {
  final List<WorkspaceSpace> spaces;
  final List<WorkspaceSchedule> schedules;
  final String? selectedSpaceId;

  const WorkspaceLoaded({
    required this.spaces,
    required this.schedules,
    required this.selectedSpaceId,
  });
}

class WorkspaceOperationSuccess extends WorkspaceState {
  final String message;
  final List<WorkspaceSpace> spaces;
  final List<WorkspaceSchedule> schedules;
  final String? selectedSpaceId;

  const WorkspaceOperationSuccess({
    required this.message,
    required this.spaces,
    required this.schedules,
    required this.selectedSpaceId,
  });
}

class WorkspaceError extends WorkspaceState {
  final String message;

  const WorkspaceError({required this.message});
}

