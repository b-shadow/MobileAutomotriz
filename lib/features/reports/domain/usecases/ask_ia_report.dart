import '../../../../core/error/result.dart';
import '../../data/models/ia_report_result.dart';
import '../repositories/reports_repository.dart';

class AskIaReport {
  final ReportsRepository repository;

  AskIaReport(this.repository);

  Future<Result<IaReportResult>> call(String prompt) {
    return repository.askIaReport(prompt);
  }
}
