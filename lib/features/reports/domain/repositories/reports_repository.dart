import '../../../../core/error/result.dart';
import '../entities/report_data.dart';

abstract class ReportsRepository {
  Future<Result<ReportData>> getReportData(String endpoint, Map<String, dynamic> queryParams);
}
