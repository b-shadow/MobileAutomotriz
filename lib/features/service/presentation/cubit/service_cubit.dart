import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/usecases/create_service.dart';
import 'package:mobile1_app/features/service/domain/usecases/get_services.dart';
import 'package:mobile1_app/features/service/domain/usecases/update_service.dart';
import 'package:mobile1_app/features/service/domain/usecases/update_service_status.dart';

import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final GetServices _getServices;
  final CreateService _createService;
  final UpdateService _updateService;
  final UpdateServiceStatus _updateServiceStatus;

  List<ServiceItem> _lastServices = const [];

  ServiceCubit({
    required GetServices getServices,
    required CreateService createService,
    required UpdateService updateService,
    required UpdateServiceStatus updateServiceStatus,
  })  : _getServices = getServices,
        _createService = createService,
        _updateService = updateService,
        _updateServiceStatus = updateServiceStatus,
        super(const ServiceInitial());

  Future<void> fetchServices() async {
    emit(const ServiceLoading());

    final result = await _getServices(const NoParams());
    switch (result) {
      case Success(:final data):
        _lastServices = data;
        emit(ServiceLoaded(services: data));
      case Err(:final failure):
        emit(ServiceError(message: failure.message));
    }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    emit(const ServiceLoading());

    final result = await _createService(CreateServiceParams(data: data));
    switch (result) {
      case Success():
        await fetchServices();
        emit(ServiceOperationSuccess(
          message: 'Servicio creado correctamente.',
          services: _lastServices,
        ));
        emit(ServiceLoaded(services: _lastServices));
      case Err(:final failure):
        emit(ServiceError(message: failure.message));
    }
  }

  Future<void> updateService({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    emit(const ServiceLoading());

    final result = await _updateService(UpdateServiceParams(id: id, data: data));
    switch (result) {
      case Success():
        await fetchServices();
        emit(ServiceOperationSuccess(
          message: 'Servicio actualizado correctamente.',
          services: _lastServices,
        ));
        emit(ServiceLoaded(services: _lastServices));
      case Err(:final failure):
        emit(ServiceError(message: failure.message));
    }
  }

  Future<void> updateServiceStatus({
    required String id,
    required bool activo,
    String? motivo,
  }) async {
    emit(const ServiceLoading());

    final result = await _updateServiceStatus(
      UpdateServiceStatusParams(id: id, activo: activo, motivo: motivo),
    );

    switch (result) {
      case Success():
        await fetchServices();
        emit(ServiceOperationSuccess(
          message: 'Estado de servicio actualizado.',
          services: _lastServices,
        ));
        emit(ServiceLoaded(services: _lastServices));
      case Err(:final failure):
        emit(ServiceError(message: failure.message));
    }
  }
}

