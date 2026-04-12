import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';

abstract class AuditState {
  const AuditState();
}

class AuditInitial extends AuditState {
  const AuditInitial();
}

class AuditLoading extends AuditState {
  const AuditLoading();
}

class AuditLoaded extends AuditState {
  final List<AuditEvent> events;
  final AuditSummary? summary;
  final AuditFilters filters;

  const AuditLoaded({
    required this.events,
    required this.summary,
    required this.filters,
  });
}

class AuditError extends AuditState {
  final String message;
  final List<AuditEvent> events;
  final AuditSummary? summary;
  final AuditFilters filters;

  const AuditError({
    required this.message,
    required this.events,
    required this.summary,
    required this.filters,
  });
}

