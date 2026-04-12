import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';
import 'package:mobile1_app/features/audit/domain/repositories/audit_repository.dart';

class GetAuditSummary implements UseCase<AuditSummary, NoParams> {
  final AuditRepository repository;

  const GetAuditSummary(this.repository);

  @override
  Future<Result<AuditSummary>> call(NoParams params) async {
    return repository.getAuditSummary();
  }
}

