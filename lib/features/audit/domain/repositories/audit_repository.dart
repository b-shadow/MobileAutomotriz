import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';

abstract class AuditRepository {
  Future<Result<List<AuditEvent>>> getAuditLogs(AuditFilters filters);
  Future<Result<AuditEvent>> getAuditDetail(String id);
  Future<Result<AuditSummary>> getAuditSummary();
}

