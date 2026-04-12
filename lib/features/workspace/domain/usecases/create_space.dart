import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class CreateSpace implements UseCase<WorkspaceSpace, CreateSpaceParams> {
  final WorkspaceRepository repository;

  const CreateSpace(this.repository);

  @override
  Future<Result<WorkspaceSpace>> call(CreateSpaceParams params) async {
    return repository.createSpace(params.data);
  }
}

class CreateSpaceParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateSpaceParams({required this.data});

  @override
  List<Object?> get props => [data];
}

