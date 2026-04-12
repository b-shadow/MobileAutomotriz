import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class GetSpaces implements UseCase<List<WorkspaceSpace>, NoParams> {
  final WorkspaceRepository repository;

  const GetSpaces(this.repository);

  @override
  Future<Result<List<WorkspaceSpace>>> call(NoParams params) async {
    return repository.getSpaces();
  }
}

