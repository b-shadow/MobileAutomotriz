import '../../../../core/error/result.dart';
import '../entities/report_data.dart';
import '../../data/models/ia_report_result.dart';

abstract class ReportsRepository {
  Future<Result<ReportData>> getReportData(String endpoint, Map<String, dynamic> queryParams);
  Future<Result<ReportData>> getExplorerData(String vista, List<String> columnas, Map<String, dynamic> filtros);
  Future<Result<IaReportResult>> askIaReport(String prompt);
  Future<Result<String>> transcribeAudioForReport(String filePath);
}
