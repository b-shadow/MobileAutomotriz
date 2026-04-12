import 'package:mobile1_app/features/service/domain/entities/service_item.dart';

abstract class ServiceState {
  const ServiceState();
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<ServiceItem> services;

  const ServiceLoaded({required this.services});
}

class ServiceOperationSuccess extends ServiceState {
  final String message;
  final List<ServiceItem> services;

  const ServiceOperationSuccess({
    required this.message,
    required this.services,
  });
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError({required this.message});
}

