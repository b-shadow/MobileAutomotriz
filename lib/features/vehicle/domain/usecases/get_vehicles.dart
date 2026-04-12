import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/repositories/vehicle_repository.dart';

class GetVehicles implements UseCase<List<Vehicle>, NoParams> {
  final VehicleRepository repository;

  const GetVehicles(this.repository);

  @override
  Future<Result<List<Vehicle>>> call(NoParams params) async {
    return repository.getVehicles();
  }
}

