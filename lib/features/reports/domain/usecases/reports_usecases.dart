import '../../../../core/error/result.dart';
import '../entities/report_entities.dart';
import '../repositories/reports_repository.dart';

class GetTopVehicles {
  final ReportsRepository repository;
  GetTopVehicles(this.repository);
  Future<Result<List<TopVehicle>>> call() => repository.getTopVehicles();
}

class GetVehicleReport {
  final ReportsRepository repository;
  GetVehicleReport(this.repository);
  Future<Result<VehicleReportDetail>> call(String placa) => repository.getVehicleReport(placa);
}
