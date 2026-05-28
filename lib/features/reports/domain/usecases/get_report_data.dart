import '../../../../core/error/result.dart';
import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetReportData {
  final ReportsRepository repository;

  GetReportData(this.repository);

  Future<Result<ReportData>> call(String endpoint, Map<String, dynamic> queryParams) {
    return repository.getReportData(endpoint, queryParams);
  }
}
