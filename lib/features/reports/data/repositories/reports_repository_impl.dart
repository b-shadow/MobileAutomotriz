import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<ReportData>> getReportData(String endpoint, Map<String, dynamic> queryParams) async {
    try {
      final data = await remoteDataSource.getReportData(endpoint, queryParams);
      return Success(data);
    } on DioException catch (e) {
      return Err(ServerFailure(message: e.response?.data['detail'] ?? 'Error de servidor'));
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }
}
