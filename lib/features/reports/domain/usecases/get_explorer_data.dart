import '../../../../core/error/result.dart';
import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetExplorerData {
  final ReportsRepository repository;

  GetExplorerData(this.repository);

  Future<Result<ReportData>> call(String vista, List<String> columnas, Map<String, dynamic> filtros) {
    return repository.getExplorerData(vista, columnas, filtros);
  }
}
