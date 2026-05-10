import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';
import 'package:mobile1_app/features/reception/domain/repositories/reception_repository.dart';

class GetReceptions implements UseCase<List<Reception>, NoParams> {
  final ReceptionRepository repository;
  GetReceptions(this.repository);

  @override
  Future<Result<List<Reception>>> call(NoParams params) =>
      repository.getReceptions();
}
