import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/domain/repositories/service_repository.dart';

class UpdateService implements UseCase<ServiceItem, UpdateServiceParams> {
  final ServiceRepository repository;

  const UpdateService(this.repository);

  @override
  Future<Result<ServiceItem>> call(UpdateServiceParams params) async {
    return repository.updateService(id: params.id, data: params.data);
  }
}

class UpdateServiceParams extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const UpdateServiceParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

