import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';

abstract class ServiceRepository {
  Future<Result<List<ServiceItem>>> getServices();

  Future<Result<ServiceItem>> createService(Map<String, dynamic> data);

  Future<Result<ServiceItem>> updateService({
    required String id,
    required Map<String, dynamic> data,
  });

  Future<Result<ServiceItem>> updateServiceStatus({
    required String id,
    required bool activo,
    String? motivo,
  });
}

