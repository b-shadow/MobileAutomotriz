import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class CancelScheduledChange implements UseCase<Map<String, dynamic>, NoParams> {
  final CompanyRepository repository;

  const CancelScheduledChange(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(NoParams params) async {
    return await repository.cancelScheduledChange();
  }
}

