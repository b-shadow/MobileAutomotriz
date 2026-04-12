import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/create_space.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/create_space_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/get_space_schedules.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/get_spaces.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/update_space_active.dart';
import 'package:mobile1_app/features/workspace/domain/usecases/update_space_schedule.dart';

import 'workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final GetSpaces _getSpaces;
  final CreateSpace _createSpace;
  final UpdateSpaceActive _updateSpaceActive;
  final GetSpaceSchedules _getSpaceSchedules;
  final CreateSpaceSchedule _createSpaceSchedule;
  final UpdateSpaceSchedule _updateSpaceSchedule;

  List<WorkspaceSpace> _spaces = const [];
  List<WorkspaceSchedule> _schedules = const [];
  String? _selectedSpaceId;

  List<WorkspaceSpace> get currentSpaces => _spaces;
  List<WorkspaceSchedule> get currentSchedules => _schedules;
  String? get currentSelectedSpaceId => _selectedSpaceId;

  WorkspaceCubit({
    required GetSpaces getSpaces,
    required CreateSpace createSpace,
    required UpdateSpaceActive updateSpaceActive,
    required GetSpaceSchedules getSpaceSchedules,
    required CreateSpaceSchedule createSpaceSchedule,
    required UpdateSpaceSchedule updateSpaceSchedule,
  })  : _getSpaces = getSpaces,
        _createSpace = createSpace,
        _updateSpaceActive = updateSpaceActive,
        _getSpaceSchedules = getSpaceSchedules,
        _createSpaceSchedule = createSpaceSchedule,
        _updateSpaceSchedule = updateSpaceSchedule,
        super(const WorkspaceInitial());

  Future<void> fetchSpaces() async {
    emit(const WorkspaceLoading());

    final spacesResult = await _getSpaces(const NoParams());
    if (spacesResult is! Success<List<WorkspaceSpace>>) {
      emit(WorkspaceError(message: (spacesResult as Err).failure.message));
      return;
    }

    _spaces = spacesResult.data;

    if (_spaces.isEmpty) {
      _selectedSpaceId = null;
      _schedules = const [];
      emit(WorkspaceLoaded(spaces: _spaces, schedules: _schedules, selectedSpaceId: null));
      return;
    }

    final stillExists = _spaces.any((space) => space.id == _selectedSpaceId);
    _selectedSpaceId = stillExists ? _selectedSpaceId : _spaces.first.id;

    await _fetchSchedulesForSelected();
    emit(_loadedState());
  }

  Future<void> selectSpace(String spaceId) async {
    if (_selectedSpaceId == spaceId) return;

    _selectedSpaceId = spaceId;
    await _fetchSchedulesForSelected();
    emit(_loadedState());
  }

  Future<void> createSpace(Map<String, dynamic> data) async {
    final result = await _createSpace(CreateSpaceParams(data: data));
    switch (result) {
      case Success():
        await fetchSpaces();
        emit(WorkspaceOperationSuccess(
          message: 'Espacio creado correctamente.',
          spaces: _spaces,
          schedules: _schedules,
          selectedSpaceId: _selectedSpaceId,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(WorkspaceError(message: failure.message));
    }
  }

  Future<void> updateSpaceActive({
    required String spaceId,
    required bool activo,
    String? motivo,
  }) async {
    final result = await _updateSpaceActive(
      UpdateSpaceActiveParams(spaceId: spaceId, activo: activo, motivo: motivo),
    );

    switch (result) {
      case Success():
        await fetchSpaces();
        emit(WorkspaceOperationSuccess(
          message: 'Estado del espacio actualizado.',
          spaces: _spaces,
          schedules: _schedules,
          selectedSpaceId: _selectedSpaceId,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(WorkspaceError(message: failure.message));
    }
  }

  Future<void> createSchedule({
    required String spaceId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _createSpaceSchedule(
      CreateSpaceScheduleParams(spaceId: spaceId, data: data),
    );

    switch (result) {
      case Success(:final data):
        _selectedSpaceId = spaceId;
        final previousSchedules = _schedules;
        await _fetchSchedulesForSelected();

        // If refresh failed or came empty unexpectedly, keep/merge local item.
        if (_schedules.isEmpty && previousSchedules.isNotEmpty) {
          _schedules = previousSchedules;
        }
        if (data.id.isNotEmpty && !_schedules.any((row) => row.id == data.id)) {
          _schedules = [..._schedules, data];
        }

        emit(WorkspaceOperationSuccess(
          message: 'Horario agregado correctamente.',
          spaces: _spaces,
          schedules: _schedules,
          selectedSpaceId: _selectedSpaceId,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(WorkspaceError(message: failure.message));
    }
  }

  Future<void> updateSchedule({
    required String spaceId,
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _updateSpaceSchedule(
      UpdateSpaceScheduleParams(
        spaceId: spaceId,
        scheduleId: scheduleId,
        data: data,
      ),
    );

    switch (result) {
      case Success(:final data):
        _selectedSpaceId = spaceId;
        final previousSchedules = _schedules;
        await _fetchSchedulesForSelected();

        if (_schedules.isEmpty && previousSchedules.isNotEmpty) {
          _schedules = previousSchedules;
        }
        if (data.id.isNotEmpty) {
          _schedules = _schedules
              .map((row) => row.id == data.id || row.id == scheduleId ? data : row)
              .toList();
        }

        emit(WorkspaceOperationSuccess(
          message: 'Horario actualizado correctamente.',
          spaces: _spaces,
          schedules: _schedules,
          selectedSpaceId: _selectedSpaceId,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(WorkspaceError(message: failure.message));
    }
  }

  Future<void> _fetchSchedulesForSelected() async {
    final selected = _selectedSpaceId;
    if (selected == null || selected.isEmpty) {
      _schedules = const [];
      return;
    }

    final result = await _getSpaceSchedules(
      GetSpaceSchedulesParams(spaceId: selected),
    );

    if (result is Success<List<WorkspaceSchedule>>) {
      _schedules = result.data;
      return;
    }
  }

  WorkspaceLoaded _loadedState() {
    return WorkspaceLoaded(
      spaces: _spaces,
      schedules: _schedules,
      selectedSpaceId: _selectedSpaceId,
    );
  }
}

