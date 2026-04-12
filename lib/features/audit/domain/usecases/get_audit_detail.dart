import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/repositories/audit_repository.dart';

class GetAuditDetail implements UseCase<AuditEvent, GetAuditDetailParams> {
  final AuditRepository repository;

  const GetAuditDetail(this.repository);

  @override
  Future<Result<AuditEvent>> call(GetAuditDetailParams params) async {
    return repository.getAuditDetail(params.id);
  }
}

class GetAuditDetailParams extends Equatable {
  final String id;

  const GetAuditDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}

