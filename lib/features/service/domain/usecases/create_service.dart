import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/repositories/service_repository.dart';

class CreateService implements UseCase<ServiceItem, CreateServiceParams> {
  final ServiceRepository repository;

  const CreateService(this.repository);

  @override
  Future<Result<ServiceItem>> call(CreateServiceParams params) async {
    return repository.createService(params.data);
  }
}

class CreateServiceParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateServiceParams({required this.data});

  @override
  List<Object?> get props => [data];
}

