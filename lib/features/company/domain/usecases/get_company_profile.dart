import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class GetCompanyProfile implements UseCase<Empresa, NoParams> {
  final CompanyRepository repository;

  GetCompanyProfile(this.repository);

  @override
  Future<Result<Empresa>> call(NoParams params) {
    return repository.getMyCompany();
  }
}
