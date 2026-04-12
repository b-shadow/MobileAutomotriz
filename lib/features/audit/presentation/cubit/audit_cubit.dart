import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';
import 'package:mobile1_app/features/audit/domain/usecases/get_audit_detail.dart';
import 'package:mobile1_app/features/audit/domain/usecases/get_audit_logs.dart';
import 'package:mobile1_app/features/audit/domain/usecases/get_audit_summary.dart';

import 'audit_state.dart';

class AuditCubit extends Cubit<AuditState> {
  final GetAuditLogs _getAuditLogs;
  final GetAuditDetail _getAuditDetail;
  final GetAuditSummary _getAuditSummary;

  List<AuditEvent> _events = const [];
  AuditSummary? _summary;
  AuditFilters _filters = const AuditFilters(ordering: '-created_at');

  AuditCubit({
    required GetAuditLogs getAuditLogs,
    required GetAuditDetail getAuditDetail,
    required GetAuditSummary getAuditSummary,
  })  : _getAuditLogs = getAuditLogs,
        _getAuditDetail = getAuditDetail,
        _getAuditSummary = getAuditSummary,
        super(const AuditInitial());

  Future<void> fetchInitial() async {
    emit(const AuditLoading());

    final summaryResult = await _getAuditSummary(const NoParams());
    if (summaryResult is Success<AuditSummary>) {
      _summary = summaryResult.data;
    }

    await _fetchLogs();
  }

  Future<void> applyFilters(AuditFilters filters) async {
    _filters = filters;
    emit(const AuditLoading());
    await _fetchLogs();
  }

  Future<void> clearFilters() async {
    _filters = const AuditFilters(ordering: '-created_at');
    emit(const AuditLoading());
    await _fetchLogs();
  }

  Future<AuditEvent?> getDetail(String id) async {
    final result = await _getAuditDetail(GetAuditDetailParams(id: id));
    switch (result) {
      case Success(:final data):
        return data;
      case Err():
        return null;
    }
  }

  Future<void> _fetchLogs() async {
    final result = await _getAuditLogs(GetAuditLogsParams(filters: _filters));
    switch (result) {
      case Success(:final data):
        _events = data;
        emit(AuditLoaded(events: _events, summary: _summary, filters: _filters));
      case Err(:final failure):
        emit(AuditError(
          message: failure.message,
          events: _events,
          summary: _summary,
          filters: _filters,
        ));
    }
  }
}

