import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class GetAvailablePlans implements UseCase<List<Plan>, NoParams> {
  final CompanyRepository repository;

  const GetAvailablePlans(this.repository);

  @override
  Future<Result<List<Plan>>> call(NoParams params) async {
    return await repository.getAvailablePlans();
  }
}
