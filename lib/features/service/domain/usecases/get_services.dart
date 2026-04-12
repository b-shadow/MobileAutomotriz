import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/repositories/service_repository.dart';

class GetServices implements UseCase<List<ServiceItem>, NoParams> {
  final ServiceRepository repository;

  const GetServices(this.repository);

  @override
  Future<Result<List<ServiceItem>>> call(NoParams params) async {
    return repository.getServices();
  }
}

