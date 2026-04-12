import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/usecases/create_vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/usecases/get_vehicles.dart';
import 'package:mobile1_app/features/vehicle/domain/usecases/update_vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/usecases/update_vehicle_status.dart';

import 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final GetVehicles _getVehicles;
  final CreateVehicle _createVehicle;
  final UpdateVehicle _updateVehicle;
  final UpdateVehicleStatus _updateVehicleStatus;

  List<Vehicle> _lastVehicles = const [];

  VehicleCubit({
    required GetVehicles getVehicles,
    required CreateVehicle createVehicle,
    required UpdateVehicle updateVehicle,
    required UpdateVehicleStatus updateVehicleStatus,
  })  : _getVehicles = getVehicles,
        _createVehicle = createVehicle,
        _updateVehicle = updateVehicle,
        _updateVehicleStatus = updateVehicleStatus,
        super(const VehicleInitial());

  Future<void> fetchVehicles() async {
    emit(const VehicleLoading());

    final result = await _getVehicles(const NoParams());
    switch (result) {
      case Success(:final data):
        _lastVehicles = data;
        emit(VehicleLoaded(vehicles: data));
      case Err(:final failure):
        emit(VehicleError(message: failure.message));
    }
  }

  Future<void> createVehicle(Map<String, dynamic> data) async {
    emit(const VehicleLoading());

    final result = await _createVehicle(CreateVehicleParams(data: data));
    switch (result) {
      case Success():
        await fetchVehicles();
        emit(VehicleOperationSuccess(
          message: 'Vehiculo creado correctamente.',
          vehicles: _lastVehicles,
        ));
        emit(VehicleLoaded(vehicles: _lastVehicles));
      case Err(:final failure):
        emit(VehicleError(message: failure.message));
    }
  }

  Future<void> updateVehicle({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    emit(const VehicleLoading());

    final result = await _updateVehicle(UpdateVehicleParams(id: id, data: data));
    switch (result) {
      case Success():
        await fetchVehicles();
        emit(VehicleOperationSuccess(
          message: 'Vehiculo actualizado correctamente.',
          vehicles: _lastVehicles,
        ));
        emit(VehicleLoaded(vehicles: _lastVehicles));
      case Err(:final failure):
        emit(VehicleError(message: failure.message));
    }
  }

  Future<void> updateVehicleStatus({
    required String id,
    required String estado,
    String? motivo,
  }) async {
    emit(const VehicleLoading());

    final result = await _updateVehicleStatus(
      UpdateVehicleStatusParams(id: id, estado: estado, motivo: motivo),
    );

    switch (result) {
      case Success():
        await fetchVehicles();
        emit(VehicleOperationSuccess(
          message: 'Estado del vehiculo actualizado.',
          vehicles: _lastVehicles,
        ));
        emit(VehicleLoaded(vehicles: _lastVehicles));
      case Err(:final failure):
        emit(VehicleError(message: failure.message));
    }
  }
}

