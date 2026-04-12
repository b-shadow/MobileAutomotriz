import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/domain/repositories/audit_repository.dart';

class GetAuditLogs implements UseCase<List<AuditEvent>, GetAuditLogsParams> {
  final AuditRepository repository;

  const GetAuditLogs(this.repository);

  @override
  Future<Result<List<AuditEvent>>> call(GetAuditLogsParams params) async {
    return repository.getAuditLogs(params.filters);
  }
}

class GetAuditLogsParams extends Equatable {
  final AuditFilters filters;

  const GetAuditLogsParams({required this.filters});

  @override
  List<Object?> get props => [filters];
}

