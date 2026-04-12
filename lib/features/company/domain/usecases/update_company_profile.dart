import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class UpdateCompanyProfileParams {
  final String? nombre;
  final String? estado;

  const UpdateCompanyProfileParams({
    this.nombre,
    this.estado,
  });
}

class UpdateCompanyProfile implements UseCase<Empresa, UpdateCompanyProfileParams> {
  final CompanyRepository repository;

  UpdateCompanyProfile(this.repository);

  @override
  Future<Result<Empresa>> call(UpdateCompanyProfileParams params) {
    return repository.updateMyCompany(
      nombre: params.nombre,
      estado: params.estado,
    );
  }
}
