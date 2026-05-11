import '../../../../core/error/result.dart';
import '../entities/report_entities.dart';

abstract class ReportsRepository {
  Future<Result<List<TopVehicle>>> getTopVehicles();
  Future<Result<VehicleReportDetail>> getVehicleReport(String placa);
}
