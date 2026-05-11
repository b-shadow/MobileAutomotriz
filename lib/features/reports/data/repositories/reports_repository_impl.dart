import '../../../../core/network/network_info.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<TopVehicle>>> getTopVehicles() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getTopVehicles();
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<VehicleReportDetail>> getVehicleReport(String placa) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getVehicleReport(placa);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }
}
