import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/audit/data/datasources/audit_remote_data_source.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_summary.dart';
import 'package:mobile1_app/features/audit/domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const AuditRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<AuditEvent>>> getAuditLogs(AuditFilters filters) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final rows = await remoteDataSource.getAuditLogs(filters);
      return Success(rows);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<AuditEvent>> getAuditDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.getAuditDetail(id);
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<AuditSummary>> getAuditSummary() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final summary = await remoteDataSource.getAuditSummary();
      return Success(summary);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

