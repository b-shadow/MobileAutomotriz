import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/models/ia_report_result.dart';
import '../datasources/reports_remote_data_source.dart';
import '../datasources/ia_report_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final IaReportRemoteDataSource iaRemoteDataSource;

  ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.iaRemoteDataSource,
  });

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

  @override
  Future<Result<IaReportResult>> askIaReport(String prompt) async {
    try {
      final result = await iaRemoteDataSource.askIaReport(prompt);
      return Success(result);
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['detail'] ?? 'Error de servidor')
          : 'Error de servidor';
      return Err(ServerFailure(message: errorMsg.toString()));
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> transcribeAudioForReport(String filePath) async {
    try {
      final text = await iaRemoteDataSource.transcribeAudio(filePath);
      return Success(text);
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Error al transcribir')
          : 'Error al transcribir';
      return Err(ServerFailure(message: errorMsg.toString()));
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }
}
